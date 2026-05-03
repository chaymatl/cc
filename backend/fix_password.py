"""Verifie le user 25 et corrige le mot de passe si necessaire."""
import io, sys
sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding='utf-8', errors='replace')

from dotenv import load_dotenv
load_dotenv()
from sqlalchemy import create_engine, text

e = create_engine("postgresql://postgres@localhost:5432/ecorewind")

with e.connect() as c:
    user = c.execute(text(
        "SELECT id, email, full_name, role, google_id, facebook_id, "
        "hashed_password, is_active, is_verified "
        "FROM users WHERE id = 25"
    )).fetchone()
    
    print(f"User #{user[0]}:")
    print(f"  Email     : {user[1]}")
    print(f"  Nom       : {user[2]}")
    print(f"  Role      : {user[3]}")
    print(f"  Google ID : {user[4]}")
    print(f"  FB ID     : {user[5]}")
    print(f"  Password  : {repr(user[6][:40] if user[6] else None)}...")
    print(f"  Active    : {user[7]}")
    print(f"  Verified  : {user[8]}")
    
    pwd = user[6]
    if pwd and not pwd.startswith("$2b$") and not pwd.startswith("$2a$"):
        print(f"\n  [!] Le mot de passe semble etre en clair ou mal formate.")
        print(f"  [!] Il va etre rehache avec bcrypt...")
        
        from passlib.context import CryptContext
        pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")
        hashed = pwd_context.hash(pwd)
        
        c.execute(text("UPDATE users SET hashed_password = :h WHERE id = 25"), {"h": hashed})
        c.commit()
        print(f"  [OK] Mot de passe rehache : {hashed[:30]}...")
    else:
        print(f"\n  [OK] Mot de passe deja hache")
