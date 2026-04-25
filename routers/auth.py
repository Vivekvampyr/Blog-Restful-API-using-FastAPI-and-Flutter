from fastapi import APIRouter,Depends,HTTPException
from models import Users
from pydantic import BaseModel
from passlib.context import CryptContext
from database import SessionLocal
from sqlalchemy.orm import Session
from typing import Annotated
from fastapi.security import OAuth2PasswordRequestForm,OAuth2PasswordBearer
from jose import jwt,JWTError
from datetime import timedelta,datetime,timezone
from pydantic import BaseModel, Field, EmailStr



router = APIRouter(prefix='/auth',tags=['auth'])

def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

db_dependency = Annotated[Session,Depends(get_db)]

SECRET_KEY = "18e1655a43c95e655417b22ef39956d295f3357d51cdc3c"
ALGORITHM = 'HS256'

bcrypt_context = CryptContext(schemes=["bcrypt"],deprecated="auto")
oauth2_bearer = OAuth2PasswordBearer(tokenUrl="auth/token")


class CreateUserRequest(BaseModel):
    username: str = Field(
        min_length=3,
        max_length=20,
        description="Username must be between 3 and 20 characters"
    )
    email: str = Field(
        description="Enter a valid email (e.g. user@example.com)",
        pattern=r'^[\w\.-]+@[\w\.-]+\.\w+$'
    )
    first_name: str = Field(
        min_length=2,
        description="First name must be at least 2 characters"
    )
    last_name: str = Field(
        min_length=2,
        description="Last name must be at least 2 characters"
    )
    password: str = Field(
        min_length=8,
        description="Password must be at least 8 characters long"
    )
    role: str = Field(
        description="Role of user: admin, writer, reader"
    )

    class Config:
        json_schema_extra = {
            "example": {
                "username": "example123",
                "email": "example@example.com",
                "first_name": "Example",
                "last_name": "Example",
                "password": "StrongPass123",
                "role": "writer"
            }
        }

class Token(BaseModel):
    access_token: str
    token_type: str

def authenticate_user(username: str,password: str,db):
    user = db.query(Users).filter(Users.username == username).first()
    if not user:
        return False
    if not bcrypt_context.verify(password,user.hashed_password):
        return False
    return user

def create_access_token(username: str,user_id: int,role: str, expires_delta: timedelta):
    encode = {'sub':username,'id':user_id,'role':role}
    expires = datetime.now(timezone.utc) + expires_delta
    encode.update({'exp':expires})
    return jwt.encode(encode,SECRET_KEY,algorithm=ALGORITHM)

async def get_current_user(token: Annotated[str,Depends(oauth2_bearer)]):
    try:
        payload = jwt.decode(token,SECRET_KEY,algorithms=[ALGORITHM])
        username: str = payload.get('sub')
        user_id: int = payload.get('id')
        role: str = payload.get('role')
        if username is None or user_id is None:
            raise HTTPException(status_code=401,detail="Not Authorized")
        return {'email':username,'id':user_id,'role':role}
    except JWTError:
        raise HTTPException(status_code=401,detail="Invalid Token")


@router.post("/token",response_model=Token)
async def login_for_access_token(form_data: Annotated[OAuth2PasswordRequestForm,Depends()],db: db_dependency):
    user = authenticate_user(form_data.username,form_data.password,db)
    if not user:
        raise HTTPException(status_code=401,detail="Invalid Credentials")
    token = create_access_token(user.username,user.id,user.role,timedelta(minutes=20))
    return {'access_token':token,'token_type':'bearer'}


@router.get("/")
def get_user(db: db_dependency):
    return db.query(Users).all()

@router.post("/user",status_code=204)
def create_user(create_user_request: CreateUserRequest, db: db_dependency):
    create_user_model = Users(
        username = create_user_request.username,
        email = create_user_request.email,
        first_name = create_user_request.first_name,
        last_name = create_user_request.last_name,
        hashed_password = bcrypt_context.hash(create_user_request.password),
        role = create_user_request.role
    )
    db.add(create_user_model)
    db.commit()
    db.refresh(create_user_model)