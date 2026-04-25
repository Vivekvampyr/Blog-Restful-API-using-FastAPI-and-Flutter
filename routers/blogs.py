from fastapi import APIRouter,Depends,Path,HTTPException
from pydantic import Field,BaseModel
from typing import Annotated
import models
from database import engine,SessionLocal
from sqlalchemy.orm import Session
from models import Blogs,Comments,Likes
from starlette import status
from .auth import get_current_user

router = APIRouter()

def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

db_dependency = Annotated[Session,Depends(get_db)]
user_dependency = Annotated[dict,Depends(get_current_user)]

class BlogRequest(BaseModel):
    title: str = Field(min_length=3)
    content: str = Field(min_length=6)
    tags: str = Field(min_length=3)
    status: bool = Field(default=False)

# def require_role(role: str):
#     def role_checker(user: dict = Depends(get_current_user)):
#         if user is None:
#             raise HTTPException(status_code=401, detail="Unauthorized")
#         if user.get("role") != role:
#             raise HTTPException(status_code=403, detail="Forbidden")
#         return user
#     return role_checker

@router.get("/blogs")
def get_blogs(db: db_dependency):
    blogs = db.query(Blogs).all()
    result = []
    for blog in blogs:
        likes_count = db.query(Likes).filter(Likes.blog_id == blog.id).count()
        comments_count = db.query(Comments).filter(Comments.blog_id == blog.id).count()
        owner = db.query(models.Users).filter(models.Users.id == blog.owner_id).first()
        result.append({
            'id': blog.id,
            'title': blog.title,
            'content': blog.content,
            'tags': blog.tags,
            'likes': likes_count,
            'comments': comments_count,
            'owner_name': owner.first_name if owner else "Unknown"
        })
    return result


@router.get("/blog/{blog_id}")
def get_blog_by_id(user: user_dependency, db: db_dependency,blog_id: int = Path(gt=0)):
    if user is None:
        raise HTTPException(status_code=401,detail="Unauthorized")
    blog_model = db.query(Blogs).filter(Blogs.id == blog_id).filter(Blogs.owner_id == user.get('id')).first()
    if blog_model is not None:
        return blog_model
    raise HTTPException(status_code=404,detail="Id not found")

@router.post("/blogs",status_code=201)
def create_blogs(user: user_dependency, db: db_dependency, blog_request: BlogRequest):
    if user is None:
        raise HTTPException(status_code=401,detail="Unauthorized")
    blog_model = Blogs(**blog_request.model_dump(),owner_id = user.get('id'))
    db.add(blog_model)
    db.commit()

@router.put("/blog/{blog_id}",status_code=200)
def update_blog(user: user_dependency, db:db_dependency, blog_id: int,blog_request: BlogRequest):
    if user is None:
        raise HTTPException(status_code=401,detail="Unauthorized")
    blog_model = db.query(Blogs).filter(Blogs.id == blog_id).filter(Blogs.owner_id == user.get('id')).first()
    if blog_model is None:
        raise HTTPException(status_code=404,detail="Id not found")
    blog_model.title = blog_request.title
    blog_model.content = blog_request.content
    blog_model.tags = blog_request.tags
    blog_model.status = blog_request.status
    db.add(blog_model)
    db.commit()

@router.delete("/blog/{blog_id}",status_code=200)
def delete_blog(user: user_dependency, db: db_dependency,blog_id: int):
    if user is None:
        raise HTTPException(status_code=401,detail="Unauthorized")
    if user.get('role') != 'writer':
        raise HTTPException(status_code=403,detail="Only Writer Are Allowed")
    blog_model = db.query(Blogs).filter(Blogs.id == blog_id).filter(Blogs.owner_id == user.get('id')).first()
    if blog_model is None:
        raise HTTPException(status_code=404,detail="Id not found")
    db.query(Blogs).filter(Blogs.id == blog_id).delete()
    db.commit()

@router.get("/blogs/search")
def get_blogs(
    db: db_dependency,
    tag: str | None = None
):
    query = db.query(Blogs)

    if tag:
        query = query.filter(Blogs.tags.contains(tag))

    return query.all()


@router.post("/blogs/{blog_id}/comments")
def add_comment(user: user_dependency,db: db_dependency,blog_id: int,content: str):
    if user is None:
        raise HTTPException(status_code=404,detail="Authentication Failed")
    comment = Comments(
        content = content,
        user_id = user.get('id'),
        blog_id = blog_id
        )
    db.add(comment)
    db.commit()

@router.get("/blogs/{blog_id}/comments")
def read_comments(db: db_dependency,blog_id: int):
    comments = db.query(Comments).filter(Comments.blog_id == blog_id).all()
    res = []
    for c in comments:
        user = db.query(models.Users).filter(models.Users.id == c.user_id).first()
        res.append({
            "id": c.id,
            "content": c.content,
            "user_id": c.user_id,
            "owner_name": user.first_name if user else "Unknown"
        })
    return res

@router.post("/blogs/{blog_id}/likes")
def add_likes(user: user_dependency,db: db_dependency,blog_id: int):
    if user is None:
        raise HTTPException(status_code=404,detail="Unauthorized")
    existing = db.query(Likes).filter(Likes.user_id == user.get('id'),Likes.blog_id == blog_id).first()
    if existing:
        raise HTTPException(status_code=400,detail="Already Liked")
    like = Likes(user_id=user.get('id'),blog_id=blog_id)
    db.add(like)
    db.commit()

@router.delete("/blogs/{blog_id}/likes")
def delete_like(user: user_dependency,db: db_dependency,blog_id: int):
    if user is None:
        raise HTTPException(status_code=404,detail="Unauthorized")
    like = db.query(Likes).filter(Likes.user_id == user.get('id'),Likes.blog_id == blog_id).first()
    if not like:
        raise HTTPException(status_code=404,detail="Like not found")
    db.delete(like)
    db.commit()

@router.get("/blogs/{blog_id}/likes")
def get_likes(db: db_dependency,blog_id: int):
    count = db.query(Likes).filter(Likes.blog_id == blog_id).count()
    return {'likes':count}



