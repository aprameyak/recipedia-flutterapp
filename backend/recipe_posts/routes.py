from flask import Blueprint, request, jsonify
from supabase import create_client
from forms import CreateRecipeForm, CommentForm
from models import Post, Notification, Profile, User, Comment
from __init__ import db
from utils import current_time
from sqlalchemy import func
import re
import random

recipe_posts = Blueprint("recipe_posts", __name__)

# Creating a Supabase client instance
SUPABASE_URL = 'https://egdumlkkfxknccmvgzxo.supabase.co'
SUPABASE_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImVnZHVtbGtrZnhrbmNjbXZnenhvIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDc5Njk2MDEsImV4cCI6MjA2MzU0NTYwMX0.9yT_wv-72Hlea4E0Rlo4p8V_aWObnvxksx1UOTdIQlc'
supabase = create_client(SUPABASE_URL, SUPABASE_KEY)

""" ************ Recipe Post views ************ """

"""Post level routes"""

@recipe_posts.route("/post", methods=["POST"])
def post():
    user = get_user(request.headers.get("Authorization", ""))
    if not user:
        return jsonify({"success": False, "error": "User not found"}), 404
    profile = get_or_create_profile(user)
    if request.data:
        data = request.get_json()
        recipe_form = CreateRecipeForm({"title": data.get("title"), "recipe": data.get("recipe"), "images": data.get("images", []), "tags": data.get("tags", []), "categories": data.get("categories", [])})
        if not recipe_form.validate():
            return jsonify({"success": False, "error": recipe_form.errors}), 400
        post = Post(profile_id = profile.id, title = recipe_form.title.data, recipe = recipe_form.recipe.data, image_uris = recipe_form.images.data, tagged_profile_ids = recipe_form.tags.data, categories = recipe_form.categories.data, timestamp = current_time(), likes_count = 0)
        #categories will be a dropdown menu
        db.session.add(post)
        db.session.flush()
        profiles_tagged = post.tagged_profile_ids
        notifications = []
        for tag in profiles_tagged:
            notif = Notification(
                notified_id = tag,
                post_id = post.id,
                type="tagged_post",
                message=f"{profile.username} has tagged you in a post!",
                timestamp = current_time()
            )
            notifications.append(notif)
        for follower in profile.followers:
            notif = Notification(
                notified_id=follower.id,  
                post_id=post.id, 
                type="new_post", 
                message=f"{profile.username} has created a new post!", 
                timestamp=current_time()
            )
            notifications.append(notif)
        db.session.add_all(notifications)
        db.session.commit() 
        return jsonify({
            "success": True, 
            "message": f"Post created and {len(notifications)} followers notified",
            "post": post.to_dict()
        }), 200
    else:
        return jsonify({"success": False, "error": "empty post cuh"}), 400

@recipe_posts.route("/post/<int:post_id>", methods=["GET"])
def view_post(post_id):
    user = get_user(request.headers.get("Authorization", ""))
    if not user:
        return jsonify({"success": False, "error": "User not found"}), 404
    post = Post.query.get(post_id)
    if post:
        return jsonify({"success": True, "post": post.to_dict()}), 200
    else:
        return jsonify({"success": False, "error": "ts don't exist"}), 404

@recipe_posts.route("/post/<int:post_id>", methods=["PUT"])
def edit_post(post_id):
    user = get_user(request.headers.get("Authorization", ""))
    if not user:
        return jsonify({"success": False, "error": "User not found"}), 404
    if request.data:
        data = request.get_json()
        recipe_form = CreateRecipeForm({"title": data.get("title"), "recipe": data.get("recipe"), "images": data.get("images", []), "tags": data.get("tags", []), "categories": data.get("categories", [])})
        if not recipe_form.validate():
            return jsonify({"success": False, "error": recipe_form.errors}), 400
        post = Post.query.get(post_id)
        if not post:
            return jsonify({"success": False, "error": "post not found"}), 404
        profile = get_or_create_profile(user)
        if post.profile_id != profile.id:
            return jsonify({"success": False, "error": "unauthorized buddy"}), 400
        post.title = recipe_form.title.data
        post.recipe = recipe_form.recipe.data
        post.image_uris = recipe_form.images.data
        post.tagged_profile_ids = recipe_form.tags.data
        post.categories = recipe_form.categories.data #categories will be a dropdown
        post.timestamp = current_time()
        db.session.commit()
        return jsonify({"success": True, "edited_post": post.to_dict()}), 200
    else:
        return jsonify({"success": False, "error": "fill in the blanks bro"}), 404

@recipe_posts.route("/post/<int:post_id>", methods=["DELETE"])
def delete_post(post_id):
    user = get_user(request.headers.get("Authorization", ""))
    if not user:
        return jsonify({"success": False, "error": "User not found"}), 400
    post = Post.query.get(post_id)
    if not post:
        return jsonify({"success": False, "error": "post not found"}), 404
    profile = get_or_create_profile(user)
    if post.profile_id != profile.id:
        return jsonify({"success": False, "error": "unauthorized buddy"}), 400
    db.session.delete(post)
    db.session.commit()
    return jsonify({"success": True}), 200

@recipe_posts.route("/post/<int:post_id>/toggle_like", methods=["PUT"])
def toggle_like_on_post(post_id):
    user = get_user(request.headers.get("Authorization", ""))
    if not user:
        return jsonify({"success": False, "error": "User not found"}), 404
    profile = get_or_create_profile(user)
    post = Post.query.get(post_id)
    if not post:
        return jsonify({"success": False, "error": "post not found"}), 404
    if post.profile_id == profile.id:
        return jsonify({"success": False, "error": "im crine bro liked his own post😹😹😹 --> not allowed here"}), 400
    if profile.has_liked_post(post):
        profile.like_post(post)
        previous_notif = Notification.query.filter_by(message = f"{profile.username} liked your post!").first()
        if not previous_notif:
            notif = Notification(notified_id = post.profile_id, post_id = post.id, type = "liked_post", message = f"{profile.username} liked your post!", timestamp = current_time())
            db.session.add(notif)
            db.session.commit()
    else:
        profile.unlike_post(post)
        db.session.commit()
    return jsonify({"success": True, "like_count": post.like_count, "liked_by": [p.to_dict() for p in post.liked_by]}), 200

@recipe_posts.route("/post/<int:post_id>/likes", methods=["GET"])
def get_all_likes(post_id):
    user = get_user(request.headers.get("Authorization", ""))
    if not user:
        return jsonify({"success": False, "error": "User not found"}), 404
    post = Post.query.get(post_id)
    if not post:
        return jsonify({"success": False, "error": "post not found"}), 404
    return jsonify({"success": True, "like_count": post.like_count, "liked_by": [p.to_dict() for p in post.liked_by]}), 200

@recipe_posts.route("/posts/<int:post_id>/comment", methods=["POST"])
def comment(post_id):
    user = get_user(request.headers.get("Authorization", ""))
    if not user:
        return jsonify({"success": False, "error": "User not found"}), 404
    profile = get_or_create_profile(user)
    post = Post.query.get(post_id)
    if not post:
        return jsonify({"success": False, "error": "post not found"}), 404
    if request.data:
        data = request.get_json()
        comment_form = CommentForm(text = data.get("comment"))
        if not comment_form.validate:
            return jsonify({"success": False, "error": comment_form.errors}), 400
        profile.comment_on_post(post, data.get("content"))
        #don't care about spam comments, each one is unique
        notif = Notification(notified_id = post.profile_id, post_id = post.id, type = "new_comment", message = f"{profile.username} commented on your post!", timestamp = current_time())
        db.session.add(notif)
        db.session.commit()
        return jsonify({"success": True, "comment": comment.to_dict()}), 200
    else:
        return jsonify({"success": False, "error": "Fill in the blanks bro"}), 404
    
@recipe_posts.route("/posts/<int:post_id>/comment/<int:comment_id>", methods=["GET"])
def get_comment(post_id, comment_id):
    user = get_user(request.headers.get("Authorization", ""))
    if not user:
        return jsonify({"success": False, "error": "User not found"}), 404
    comment = Comment.query.get(comment_id)
    if not comment:
        return jsonify({"success": False, "error": "no comment luh bruh"}), 404
    return jsonify({"success": True, "comment": comment.to_dict()}), 200

@recipe_posts.route("/posts/<int:post_id>/comment/<int:comment_id>", methods=["PUT"])
def edit_comment(post_id, comment_id):
    user = get_user(request.headers.get("Authorization", ""))
    if not user:
        return jsonify({"success": False, "error": "User not found"}), 404
    post = Post.query.get(post_id)
    if not post:
        return jsonify({"success": False, "error": "post not found"}), 404
    comment = Comment.query.get(comment_id)
    if not comment:
        return jsonify({"success": False, "error": "comment not found"}), 404
    profile = get_or_create_profile(user)
    if comment.profile_id != profile.id:
        return jsonify({"success": False, "error": "unauthorized buddy"}), 400
    if request.data:
        data = request.get_json()
        comment_form = CommentForm(text = data.get("comment"))
        if not comment_form.validate:
            return jsonify({"success": False, "error": comment_form.errors}), 400
        comment.content = data.get("comment")
        db.session.commit()
        return jsonify({"success": False, "comment": [c.to_dict() for c in comment]}), 200
    else:
        return jsonify({"success": False, "error": "nothing there blud"}), 404

@recipe_posts.route("/posts/<int:post_id>/comment/<int:comment_id>", methods=["DELETE"])
def delete_comment(post_id, comment_id):
    user = get_user(request.headers.get("Authorization", ""))
    if not user:
        return jsonify({"success": False, "error": "User not found"}), 404
    profile = get_or_create_profile(user)
    profile.delete_comment_on_post(comment_id) #handles the case of unauthorization already
    return jsonify({"success": True}), 200

@recipe_posts.route("/posts/<int:post_id>/comments", methods=["GET"])
def get_all_comments(post_id):
    user = get_user(request.headers.get("Authorization", ""))
    if not user:
        return jsonify({"success": False, "error": "User not found"}), 404
    post = Post.query.get(post_id)
    if not post:
        return jsonify({"success": False, "error": "post not found"}), 404
    comments = post.comments
    return jsonify({"success": True, "comments": [c.to_dict for c in comments]}), 200

"""General recipe_posts level routes (not user feed)"""

@recipe_posts.route("/search", methods=["GET"])
def search():
    user = get_user(request.headers.get("Authorization", ""))
    if not user:
        return jsonify({"success": False, "error": "User not found"}), 404
    # data might not actually be there, so it's not required --> use request.args.get("q") (query)
    q = request.args.get("q").strip()
    if not q:
        popular_posts = Post.query.order_by(Post.like_count.desc()).limit(40).all()
        popular_profiles = Profile.query.order_by(func.count(Profile.followers).desc()).limit(10).all()
        return jsonify({"success": True, "default_search_page": True, "popular_posts": [p.to_dict() for p in popular_posts], "popular_profiles": [p.to_dict() for p in popular_profiles]}), 200
    if len(q) > 100:
        return jsonify({"success": False, "error": "search too long"}), 400
    if not re.match(r'^[a-zA-Z0-9\s\-_.@\']+$', q):
        return jsonify({"success": False, "error": "invalid input sorry"}), 400
    posts = Post.query.filter(func.lower(Post.title).like(func.lower(f'%{q}%')) | func.lower(Post.content).like(func.lower(f'%{q}%'))).order_by(Post.likes_count.desc()).limit(40).all()
    profiles = Profile.query.filter(func.lower(Profile.username).like(func.lower(f'%{q}%'))|func.lower(Profile.bio).like(func.lower(f'%{q}%'))).order_by(func.count(Profile.followers).desc()).limit(10).all()
    return jsonify({"success": True, "default_search_page": False, "exact_match_posts": [p.to_dict() for p in posts.to_dict], "exact_match_profiles": [p.to_dict() for p in profiles.to_dict]}), 200

@recipe_posts.route("/category", methods=["GET"])
def category(category_str):
    user = get_user(request.headers.get("Authorization", ""))
    if not user:
        return jsonify({"success": False, "error": "User not found"}), 404
    # data might not actually be there, so it's not required --> use request.args.get("q") (query)
    # categories won't be text-inputtable, will be buttons
    q = request.args.get("q")
    if not q:
        return jsonify({"success": True, "categories_available": ["proteins", "keto", "calorie-friendly", "drinks", "healthy", "luxurious", "carbs", "cheap & fast", "vegetarian", "trending", "random", "recent"]}), 200
    posts = Post.query.filter_by(categories = q).limit(50).all()
    return jsonify({"success": True, "posts": [p.to_dict() for p in posts]}), 200

@recipe_posts.route("/recent", methods=["GET"])
def get_recents():
    user = get_user(request.headers.get("Authorization", ""))
    if not user:
        return jsonify({"success": False, "error": "User not found"}), 404
    recent_posts = Post.query.order_by(Post.timestamp.desc()).limit(50).all()
    return jsonify({"success": True, "recent_posts": [p.to_dict() for p in recent_posts]}), 200

@recipe_posts.route("/random", methods=["GET"])
def get_random():
    user = get_user(request.headers.get("Authorization", ""))
    if not user:
        return jsonify({"success": False, "error": "User not found"}), 404
    random_indices = random.sample(range(Post.query.count()), 50)
    random_posts = [Post.query.offset(i).first() for i in random_indices]
    return jsonify({"success": True, "random_posts": [p.to_dict() for p in random_posts]}), 200

@recipe_posts.route("/trending", methods=["GET"])
def get_trending():
    user = get_user(request.headers.get("Authorization", ""))
    if not user:
        return jsonify({"success": False, "error": "User not found"}), 404
    popular_posts = Post.query.order_by(Post.like_count.desc()).limit(50).all()
    return jsonify({"success": True, "popular_posts": [p.to_dict() for p in popular_posts]}), 200
    
""" ************ Helper functions ************ """

def get_user(auth_header):
    token = auth_header.replace("Bearer ", "")
    user_response = supabase.auth.get_user(token)
    auth_user = user_response.user
    db_user = User.query.filter_by(id=auth_user.id).first()
    return db_user

def get_or_create_profile(user):
    profile = Profile.query.filter_by(user_id=user.id).first()
    if not profile:
        profile = Profile(
            user_id=user.id,
            bio=f"Hi, I'm {user.email}.",
            username=user.email,
            profile_picture_uri="https://i.pinimg.com/474x/9e/83/75/9e837528f01cf3f42119c5aeeed1b336.jpg?nii=t",
            account_created=current_time(),
            light_mode=True,
            language="English"
        )
        db.session.add(profile)
        db.session.commit()
    return profile