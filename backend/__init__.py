from flask import Flask
from flask_sqlalchemy import SQLAlchemy
from flask_cors import CORS

db = SQLAlchemy()

def create_app(test_config=None):
    app = Flask(__name__)
    CORS(app)
    app.config['SQLALCHEMY_DATABASE_URI'] = "postgresql://postgres:password@db.egdumlkkfxknccmvgzxo.supabase.co:5432/postgres"
    db.init_app(app)

    # internal imports (no circular imports)
    from users.routes import users
    from recipe_posts.routes import recipe_posts
    app.register_blueprint(users)
    app.register_blueprint(recipe_posts)

    return app

if __name__ == "__main__":
    app = create_app()
    app.run(host='0.0.0.0', port=5000)
