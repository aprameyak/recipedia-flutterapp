from __init__ import db
from utils import current_time

class User(db.Model):
    __tablename__ = 'user'
    id = db.Column(db.String, primary_key=True)
    email = db.Column(db.String)
    created_at = db.Column(db.DateTime)
    updated_at = db.Column(db.DateTime)

#TODO FOR THE FUTURE: Implement a vectordb running at all times & discard exact match for searches
class Post(db.Model):
    __tablename__ = 'posts'
    id = db.Column(db.Integer, primary_key=True, autoincrement=True)
    user_id = db.Column(db.Integer, db.ForeignKey('user.id'))
    user = db.Relationship('User', backref = 'posts', lazy=True) #gives us Post.user and User.posts
    title = db.Column(db.String(50))
    recipe = db.Column(db.String(500))
    image_uris = db.Column(db.JSON)
    categories = db.Column(db.JSON)
    tagged_profile_ids = db.Column(db.JSON)
    timestamp = db.Column(db.DateTime, default=current_time()) 

    def get_share_post_link(self):
        return f"http://localhost:5000/post/{id}"
    
    @property
    def like_count(self):
        return self.liked_by.count()
    
    @property
    def liked_by(self):
        return self.liked_by.all()

    @property
    def comment_count(self):
        return self.comments.count()
    
    @property
    def commented_by(self):
        return [comment.profile for comment in self.comments]
    
class Comment(db.Model):
    __tablename__ = 'post_comments'
    id = db.Column(db.Integer, primary_key=True)
    profile_id = db.Column(db.Integer, db.ForeignKey('profiles.id'))
    post_id = db.Column(db.Integer, db.ForeignKey('posts.id'))
    content = db.Column(db.Text)
    created_at = db.Column(db.DateTime, default=current_time())
    profile = db.relationship('Profile', backref='comments') #gives us Comment.profile and Profile.comments
    post = db.relationship('Post', backref='comments') #gives us Comment.post and Post.comments

#TODO FOR THE FUTURE: Add notifications on/off
#TODO FOR THE FUTURE: Add event driven architecture, use kafka for eventbus
class Notification(db.Model):
    __tablename__ = 'notifications'
    id = db.Column(db.Integer, primary_key=True, autoincrement=True)
    notified_id = db.Column(db.Integer, db.ForeignKey('profiles.id'))
    post_id = db.Column(db.Integer, db.ForeignKey('posts.id'))
    post = db.Relationship('Post', backref = 'notifications', lazy=True) #gives us Notification.post and Post.notifications
    notif_type = db.Column(db.String(50)) #Either liked_post, new_post, new_comment, new_follower, tagged_post
    message = db.Column(db.String(200))
    timestamp = db.Column(db.DateTime, default=current_time())
    read = db.Column(db.Boolean, default = False)

followers_association = db.Table('followers',
    db.Column('follower_id', db.Integer, db.ForeignKey('profiles.id'), primary_key=True),
    db.Column('following_id', db.Integer, db.ForeignKey('profiles.id'), primary_key=True),
    db.Column('created_at', db.DateTime, default = current_time())
)

post_likes = db.Table('post_likes',
    db.Column('profile_id', db.Integer, db.ForeignKey('profiles.id'), primary_key=True),
    db.Column('post_id', db.Integer, db.ForeignKey('posts.id'), primary_key=True),
    db.Column('created_at', db.DateTime, default=current_time())
)

#TODO FOR THE FUTURE: Add profile.tagged_posts
#TODO FOR THE FUTURE: Add profile.collections (like a pinterest board)
class Profile(db.Model):
    __tablename__ = 'profiles'
    id = db.Column(db.Integer, primary_key=True, autoincrement=True)
    user_id = db.Column(db.Integer, db.ForeignKey('user.id'))
    user = db.Relationship('User', backref = 'Profile', lazy=True) #gives us Profile.user and User.profile
    bio = db.Column(db.String(300))
    username = db.Column(db.String(100))
    profile_picture_uri = db.Column(db.String(255))
    posts = db.relationship('Post',
                            primaryjoin='Profile.user_id == Post.user_id',
                            backref='author',
                            lazy=True) #gives us Profile.posts and Post.author
    notifications = db.relationship('Notification', backref='profile', lazy=True) #gives us Profile.notifications and Notification.profile
    account_created = db.Column(db.DateTime, default=current_time())
    liked_posts = db.relationship('Post', 
                                secondary=post_likes,
                                backref=db.backref('liked_by', lazy='dynamic'),
                                lazy='dynamic') #gives us Profile.liked_posts and Post.like_by
    light_mode = db.Column(db.Boolean, default=True)
    language = db.Column(db.String(50), default="English")
    #Later down the road, switch followers and following to a graphDB for better mutual suggestions
    following = db.relationship('Profile', 
                                secondary = followers_association,
                                primaryjoin=id == followers_association.c.follower_id,
                                secondaryjoin=id == followers_association.c.following_id,
                                backref = 'followers',
                                lazy='dynamic'
                                )

    def follow(self, profile):
        self.following.append(profile) #backref is auto updated in association table
    
    def unfollow(self, profile):
        if profile in self.following:
            self.following.remove(profile)

    def is_following(self, profile):
        return profile in self.following

    def like_post(self, post):
        self.liked_posts.append(post) #backref is auto updated in association table

    def unlike_post(self, post):
        if post in self.liked_posts:
            self.liked_posts.remove(post)

    def has_liked_post(self, post):
        return post in self.liked_posts
    
    def comment_on_post(self, post, content):
        comment = Comment(profile = self, post = post, content = content)
        db.session.add(comment)
        db.session.commit()

    def delete_comment_on_post(self, comment_id):
        comment = Comment.query.filter_by(id = comment_id, profile_id = self.id).first()
        if comment:
            db.session.delete(comment)
            db.session.commit()
    
    def has_commented_on_post(self, post):
        return Comment.query.filter_by(profile_id=self.id, post_id=post.id).first() is not None #most efficient approach
    
    def get_commented_posts(self):
        return [comment.post for comment in self.comments]

    def get_share_profile_link(self):
        #TODO change this
        return f"http://localhost:5000/profile/{id}"
