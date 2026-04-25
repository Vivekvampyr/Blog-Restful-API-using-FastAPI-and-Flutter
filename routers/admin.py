from fastapi import APIRouter,Depends,Path,HTTPException
from pydantic import Field,BaseModel
from typing import Annotated
import models
from database import engine,SessionLocal
from sqlalchemy.orm import Session
from models import Blogs,Comments
from starlette import status
from .auth import get_current_user

router = APIRouter(prefix='/admin',tags=['admin'])


class BlogRequest(BaseModel):
    title: str = Field(min_length=3)
    content: str = Field(min_length=6)
    tags: str = Field(min_length=3)
    status: bool = Field(default=False)

def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

db_dependency = Annotated[Session,Depends(get_db)]
user_dependency = Annotated[dict,Depends(get_current_user)]


@router.get("/blog")
async def read_all(user: user_dependency,db: db_dependency):
    if user is None or user.get('role') != 'admin':
        raise HTTPException(status_code=401,detail="Unauthorized")
    return db.query(Blogs).all()

@router.delete("/blog/{blog_id}",status_code=200)
def delete_blog(user: user_dependency,db: db_dependency,blog_id: int = Path(gt=0)):
    if user is None or user.get('role') != 'admin':
        raise HTTPException(status_code=401,detail="Unauthorized")
    blog_model = db.query(Blogs).filter(Blogs.id == blog_id).first()
    if blog_model is None:
        raise HTTPException(status_code=404,detail="ID not found")
    db.query(Blogs).filter(Blogs.id == blog_id).delete()
    db.commit()

@router.get("/comments")
def read_all_comments(blog_id: int,user: user_dependency,db: db_dependency):
    if user is None or user.get('role') != 'admin':
        raise HTTPException(status_code=401,detail="Unauthenticated")
    return db.query(Comments).filter(Comments.blog_id == blog_id).all()
    

@router.delete("/comment/{blog_id}/{comment_id}")
def delete_comment(user: user_dependency,db: db_dependency,blog_id:int,comment_id: int):
    if user is None or user.get('role') != 'admin':
        raise HTTPException(status_code=401,detail="Unauthorized")
    comment_model = db.query(Comments).filter(Comments.blog_id == blog_id).filter(Comments.id == comment_id).first()
    if comment_model is None:
        raise HTTPException(status_code=404,detail="Comment Id not found")
    db.delete(comment_model)
    db.commit()

