from fastapi import APIRouter,Depends,Path,HTTPException
from pydantic import Field,BaseModel
from typing import Annotated
import models
from database import engine,SessionLocal
from sqlalchemy.orm import Session
from models import Blogs,Comments,Likes,Users
from starlette import status
from .auth import get_current_user
from passlib.context import CryptContext

router = APIRouter(prefix='/user',tags=['user'])

def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

db_dependency = Annotated[Session,Depends(get_db)]
user_dependency = Annotated[dict,Depends(get_current_user)]
bcrypt_context = CryptContext(schemes=["bcrypt"],deprecated="auto")

class UserVerification(BaseModel):
    password: str
    new_password: str = Field(min_length=8)

@router.get("/")
def get_user(user: user_dependency,db: db_dependency):
    if user is None:
        raise HTTPException(status_code=401,detail="Unauthorized")
    return db.query(Users).filter(Users.id == user.get('id')).first()

@router.put("/password")
def change_password(user: user_dependency,db: db_dependency,user_verification_request: UserVerification):
    if user is None:
        raise HTTPException(status_code=401,detail="Unauthorized")
    user_model = db.query(Users).filter(Users.id == user.get('id')).first()
    if not bcrypt_context.verify(user_verification_request.password,user_model.hashed_password):
        raise HTTPException(status_code=401,detail="Error on password change")
    user_model.hashed_password = bcrypt_context.hash(user_verification_request.new_password)
    db.add(user_model)
    db.commit()
