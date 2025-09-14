from flask_wtf import FlaskForm
from wtforms import StringField, TextAreaField, SubmitField, FieldList
from wtforms.validators import (
    InputRequired,
    Length,
    ValidationError
)
from models import Profile

class SearchPostForm(FlaskForm):
    search_query = StringField(
        "Query", validators=[InputRequired(), Length(min=1, max=100)]    
    )
    submit_search = SubmitField("Search")

class CreateRecipeForm(FlaskForm):
    title = StringField("Title", validators=[InputRequired(), Length(min=1, max=50)])
    recipe = TextAreaField("Recipe", validators=[InputRequired(), Length(min=1, max=500)])
    images = FieldList(StringField("Recipe Image", validators=[InputRequired(), Length(max=500)]), min_entries=1, max_entries=10)
    categories = FieldList(StringField("Recipe Category", validators=[InputRequired(), Length(min=1, max=50)]), min_entries = 0, max_entries = 10)
    tags = FieldList(StringField("Tags", validators=[Length(min=1, max=100)]), min_entries=0, max_entries=10)
    submit_recipe = SubmitField("Post Recipe")

class CommentForm(FlaskForm):
    text = TextAreaField(
        "Comment", validators=[InputRequired(), Length(min=1, max=500)]
    )
    submit_comment = SubmitField("Enter Comment")

class UpdateUserNameForm(FlaskForm):
    username = StringField("Username", validators=[InputRequired(), Length(min=1, max=40)])
    submit_username = SubmitField("Username")
    def validate_username(self, username):
        user = Profile.query.filter_by(username=username.data).first()
        if user is not None:
            raise ValidationError("Username is taken")

class UpdateProfilePicForm(FlaskForm):
    picture = StringField("Profile Picture", validators=[InputRequired(), Length(min=1, max=255)])
    submit_picture = SubmitField("Update profile picture")

class UpdateBioForm(FlaskForm):
    bio = TextAreaField("Bio", validators=[InputRequired(), Length(min=1, max=300)])
    submit_bio = SubmitField("Update bio")