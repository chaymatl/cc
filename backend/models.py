from pydantic import BaseModel, EmailStr
from typing import Optional, List
from datetime import datetime

class UserBase(BaseModel):
    email: str
    full_name: Optional[str] = None
    role: str = "user"
    qr_code: Optional[str] = None

class UserCreate(BaseModel):
    email: str
    full_name: Optional[str] = None
    role: str = "user"
    password: str

class User(UserBase):
    id: int
    is_active: bool = True

    class Config:
        from_attributes = True

class Token(BaseModel):
    access_token: str
    refresh_token: Optional[str] = None
    token_type: str
    role: str
    id: int
    email: str
    full_name: Optional[str] = None
    qr_code: Optional[str] = None

class RefreshTokenRequest(BaseModel):
    refresh_token: str

class TokenData(BaseModel):
    email: Optional[str] = None

class GoogleAuth(BaseModel):
    token: str

class FacebookAuth(BaseModel):
    access_token: str

class ForgotPassword(BaseModel):
    email: str

class ResetPassword(BaseModel):
    token: str
    new_password: str

class PostBase(BaseModel):
    user_name: str
    user_avatar_url: str
    image_url: str
    description: str

class PostCreate(PostBase):
    pass

class CommentBase(BaseModel):
    user_name: str
    user_avatar_url: Optional[str] = None
    content: str

class CommentCreate(CommentBase):
    parent_id: Optional[int] = None

class Comment(CommentBase):
    id: int
    user_id: int
    post_id: int
    parent_id: Optional[int] = None
    created_at: datetime

    class Config:
        from_attributes = True

class CommentUpdate(BaseModel):
    content: str

class Post(PostBase):
    id: int
    user_id: int
    created_at: datetime
    likes_count: int
    status: str = "published"
    comments: List[Comment] = []

    class Config:
        from_attributes = True

class PostUpdate(BaseModel):
    description: Optional[str] = None
    image_url: Optional[str] = None

class UserSmall(BaseModel):
    id: int
    full_name: str
    email: str

    class Config:
        from_attributes = True

class UserUpdate(BaseModel):
    full_name: Optional[str] = None
    role: Optional[str] = None
    password: Optional[str] = None

class ChangePasswordRequest(BaseModel):
    old_password: str
    new_password: str

class OTPSendRequest(BaseModel):
    identifier: str  # email or phone
    method: str = "email"  # "email" or "sms"

class OTPVerifyRequest(BaseModel):
    identifier: str
    code: str

class QRVerifyRequest(BaseModel):
    qr_code: str

# --- Testimonials ---

class TestimonialCreate(BaseModel):
    content: str
    rating: int = 5  # 1-5

class TestimonialResponse(BaseModel):
    id: int
    user_id: Optional[int] = None
    user_name: Optional[str] = None
    user_avatar_url: Optional[str] = None
    content: str
    rating: int
    is_approved: bool = False
    is_featured: bool = False
    created_at: datetime

    class Config:
        from_attributes = True

# --- Collection Points (Admin CRUD) ---

class CollectionPointCreate(BaseModel):
    name: str
    lat: str
    lng: str
    is_verified: bool = False
    types: str = ""  # comma-separated
    address: Optional[str] = None
    hours: Optional[str] = None
    status: str = "disponible"
    load_level: str = "0.0"

class CollectionPointUpdate(BaseModel):
    name: Optional[str] = None
    lat: Optional[str] = None
    lng: Optional[str] = None
    is_verified: Optional[bool] = None
    types: Optional[str] = None
    address: Optional[str] = None
    hours: Optional[str] = None
    status: Optional[str] = None
    load_level: Optional[str] = None

class CollectionPointResponse(BaseModel):
    id: int
    name: str
    lat: str
    lng: str
    is_verified: bool
    types: str
    address: Optional[str] = None
    hours: Optional[str] = None
    status: str
    load_level: str
    created_at: datetime

    class Config:
        from_attributes = True

# --- Centre Proposals ---

class CenterProposalCreate(BaseModel):
    name: str
    address: str
    lat: Optional[str] = None
    lng: Optional[str] = None
    waste_types: str = ""  # comma-separated
    description: Optional[str] = None

class CenterProposalResponse(BaseModel):
    id: int
    user_id: int
    user_name: Optional[str] = None
    name: str
    address: str
    lat: Optional[str] = None
    lng: Optional[str] = None
    waste_types: str
    description: Optional[str] = None
    status: str
    created_at: datetime

    class Config:
        from_attributes = True
