from database import Base
from sqlalchemy import Column,Integer,String,Boolean,ForeignKey,UniqueConstraint
from sqlalchemy.orm import relationship


class Blogs(Base):
    __tablename__ = 'blogs'

    id = Column(Integer,primary_key=True,index=True)
    title = Column(String)
    content = Column(String)
    tags = Column(String)
    status = Column(Boolean,default=False)
    owner_id = Column(Integer,ForeignKey('users.id'))
    comments = relationship("Comments", backref="blog")
    likes = relationship("Likes", backref="blog")

class Users(Base):
    __tablename__ = 'users'

    id = Column(Integer,primary_key=True,index=True)
    email = Column(String)
    username = Column(String)
    first_name = Column(String)
    last_name = Column(String)
    hashed_password = Column(String)
    is_active = Column(Boolean,default=True)
    role = Column(String)
    comments = relationship("Comments", backref="user")
    likes = relationship("Likes", backref="user")

class Comments(Base):
    __tablename__ = 'comments'

    id = Column(Integer,primary_key=True,index=True)
    content = Column(String)
    blog_id = Column(Integer,ForeignKey('blogs.id'))
    user_id = Column(Integer,ForeignKey('users.id'))

class Likes(Base):
    __tablename__ = 'likes'

    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id"))
    blog_id = Column(Integer, ForeignKey("blogs.id"))

    __table_args__ = (
        UniqueConstraint('user_id','blog_id',name='unique_user_blog_like'),
    )