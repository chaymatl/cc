from sqlalchemy import Boolean, Column, Integer, String, ForeignKey, DateTime, Text, Float
from sqlalchemy.orm import relationship
from datetime import datetime, timedelta
import uuid
from database import Base

def generate_unique_qr_token():
    """Generate a cryptographically unique QR code token.
    Format: ECOREWIND-XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX
    This guarantees global uniqueness (UUID4 = 122 bits of randomness)."""
    return f"ECOREWIND-{uuid.uuid4()}"

class User(Base):
    __tablename__ = "users"

    id = Column(Integer, primary_key=True, index=True)
    email = Column(String, unique=True, index=True)
    full_name = Column(String)
    hashed_password = Column(String)
    is_active = Column(Boolean, default=True)
    is_verified = Column(Boolean, default=False)
    role = Column(String, default="user") # user, admin, educator, intercommunality, pointManager, collector
    google_id = Column(String, unique=True, index=True, nullable=True)
    facebook_id = Column(String, unique=True, index=True, nullable=True)
    qr_code = Column(String, unique=True, index=True, nullable=False, default=generate_unique_qr_token)
    reset_token = Column(String, unique=True, index=True, nullable=True)
    token_expires = Column(String, nullable=True)
    avatar_url = Column(String, nullable=True)  # URL de la photo de profil
    global_score = Column(Float, default=0.0)  # Score global de l'utilisateur

    posts = relationship("Post", back_populates="author")
    saved_posts = relationship("SavedPost", back_populates="user")
    likes = relationship("Like", back_populates="user")

class Post(Base):
    __tablename__ = "posts"

    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id"))
    user_name = Column(String)
    user_avatar_url = Column(String)
    image_url = Column(String)
    description = Column(Text)
    created_at = Column(DateTime, default=datetime.utcnow)
    likes_count = Column(Integer, default=0)
    # --- AI Moderation ---
    status = Column(String, default="published")  # published | pending_review | rejected
    moderation_score = Column(Float, default=0.0)  # 0.0 (safe) .. 1.0 (dangerous)
    moderation_reason = Column(String, nullable=True)  # Short human-readable reason
    moderation_details = Column(Text, nullable=True)  # JSON: full AI analysis

    author = relationship("User", back_populates="posts")
    savers = relationship("SavedPost", back_populates="post")
    liked_by = relationship("Like", back_populates="post")
    comments = relationship("Comment", back_populates="post")

class SavedPost(Base):
    __tablename__ = "saved_posts"

    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id"))
    post_id = Column(Integer, ForeignKey("posts.id"))
    saved_at = Column(DateTime, default=datetime.utcnow)

    user = relationship("User", back_populates="saved_posts")
    post = relationship("Post", back_populates="savers")

class Like(Base):
    __tablename__ = "likes"

    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id"))
    post_id = Column(Integer, ForeignKey("posts.id"))
    created_at = Column(DateTime, default=datetime.utcnow)

    user = relationship("User", back_populates="likes")
    post = relationship("Post", back_populates="liked_by")

class Comment(Base):
    __tablename__ = "comments"

    id = Column(Integer, primary_key=True, index=True)
    post_id = Column(Integer, ForeignKey("posts.id"))
    user_id = Column(Integer, ForeignKey("users.id"))
    user_name = Column(String)
    user_avatar_url = Column(String, nullable=True)
    content = Column(Text)
    parent_id = Column(Integer, ForeignKey("comments.id"), nullable=True)
    created_at = Column(DateTime, default=datetime.utcnow)

    post = relationship("Post", back_populates="comments")
    replies = relationship("Comment", backref="parent", remote_side=[id], lazy="joined")

class OTPCode(Base):
    __tablename__ = "otp_codes"

    id = Column(Integer, primary_key=True, index=True)
    identifier = Column(String, index=True)  # email or phone
    code = Column(String)
    purpose = Column(String, default="register")  # register, reset
    created_at = Column(DateTime, default=datetime.utcnow)
    expires_at = Column(DateTime)
    is_used = Column(Boolean, default=False)

class Notification(Base):
    __tablename__ = "notifications"

    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id"), index=True)  # recipient
    type = Column(String)  # like, comment, save
    title = Column(String)
    body = Column(String)
    from_user_name = Column(String)
    post_id = Column(Integer, nullable=True)
    comment_id = Column(Integer, nullable=True)  # ID of the comment that triggered the notification
    is_read = Column(Boolean, default=False)
    created_at = Column(DateTime, default=datetime.utcnow)

class CollectionPoint(Base):
    __tablename__ = "collection_points"

    id = Column(Integer, primary_key=True, index=True)
    name = Column(String, nullable=False)
    lat = Column(String, nullable=False)
    lng = Column(String, nullable=False)
    is_verified = Column(Boolean, default=False)
    types = Column(String, default="")  # Comma-separated: "plastique,verre,papier"
    address = Column(String, nullable=True)
    hours = Column(String, nullable=True)
    status = Column(String, default="disponible")  # disponible, saturé, maintenance
    load_level = Column(String, default="0.0")
    created_at = Column(DateTime, default=datetime.utcnow)

class Testimonial(Base):
    __tablename__ = "testimonials"

    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id"), nullable=True)
    user_name = Column(String, nullable=False)
    user_avatar_url = Column(String, nullable=True)
    content = Column(Text, nullable=False)
    rating = Column(Integer, default=5)  # 1-5 stars
    is_approved = Column(Boolean, default=False)  # Admin must approve
    is_featured = Column(Boolean, default=False)  # Featured on landing page
    created_at = Column(DateTime, default=datetime.utcnow)

    user = relationship("User")

class CenterProposal(Base):
    __tablename__ = "center_proposals"

    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id"), index=True)
    user_name = Column(String)
    name = Column(String)
    address = Column(String)
    lat = Column(String, nullable=True)
    lng = Column(String, nullable=True)
    waste_types = Column(String, default="")
    description = Column(Text, nullable=True)
    status = Column(String, default="pending")  # pending, approved, rejected
    created_at = Column(DateTime, default=datetime.utcnow)

    user = relationship("User")


class Quiz(Base):
    __tablename__ = "quizzes"

    id = Column(Integer, primary_key=True, index=True)
    educator_id = Column(Integer, ForeignKey("users.id"), index=True)
    title = Column(String, nullable=False)
    description = Column(Text, nullable=True)
    pdf_filename = Column(String, nullable=False)          # fichier PDF original
    questions_json = Column(Text, nullable=True)            # Questions extraites par Gemini (JSON)
    answer_key_json = Column(Text, nullable=True)           # Corrigé généré par Gemini (JSON)
    total_questions = Column(Integer, default=0)
    status = Column(String, default="processing")           # processing | ready | error
    error_message = Column(Text, nullable=True)
    created_at = Column(DateTime, default=datetime.utcnow)

    educator = relationship("User")
    submissions = relationship("QuizSubmission", back_populates="quiz")


class QuizSubmission(Base):
    __tablename__ = "quiz_submissions"

    id = Column(Integer, primary_key=True, index=True)
    quiz_id = Column(Integer, ForeignKey("quizzes.id"), index=True)
    student_id = Column(Integer, ForeignKey("users.id"), index=True)
    student_name = Column(String)
    answers_json = Column(Text, nullable=True)              # Réponses de l'étudiant (JSON)
    score = Column(Float, nullable=True)                     # Note sur 10
    max_score = Column(Float, default=10.0)
    feedback_json = Column(Text, nullable=True)             # Feedback détaillé par question (JSON)
    ai_graded = Column(Boolean, default=False)              # True si corrigé par Gemini
    submitted_at = Column(DateTime, default=datetime.utcnow)
    graded_at = Column(DateTime, nullable=True)

    quiz = relationship("Quiz", back_populates="submissions")
    student = relationship("User")
