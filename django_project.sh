# Shell script to create a complete Django project.
# This script require Python 3.x and pyenv and Django 1.10

# The project contains:
# Settings config
# model and form
# list and detial
# create, update and delete
# Admin config
# Tests
# Selenium test
# Manage shell

# Usage:
# Type the following command, you can change the project name.

# source django_project.sh tutorial

# Colors
red='tput setaf 1'
green='tput setaf 2'
reset='tput sgr0' # Turn off all attributes

PROJECT=${1-tutorial}

echo "${green}>>> The name of the project is '$PROJECT'.${reset}"

echo "${green}>>> Creating djangoproject${reset}"
if [ ! -d djangoproject ]; then mkdir djangoproject; fi
cd djangoproject

echo "${green}>>> Creating virtualenv${reset}"
python -m env .env
echo "${green}>>> .env is created${reset}"

#active
sleep 2
echo "${green}>>> activate the .env${reset}"
source env/bin/activate
PS1="(`basename \"$VIRTUAL_ENV\"`)\e[1;34m:/\W\e[00m$ "
sleep 2

# installdjango
echo "${green}>>> Installing the Django${reset}"
pip install -U pip
pip install django=1.10 dj-database0url django-database-filter django-localflavor django-widget-tweaks python-decouple pytz selenium django-extensions
pip freeze > requirements.txt

# Create contrib/env-sample
echo "${green}>>> Creating the contrib/env-sample${reset}"
mkdir contrib
cat << EOF > contirb/env-sample
SECRET_KEY=''
ALLOWED_HOSTS=127.0.0.1, .localhost
EOF

echo "${green}>>> Copy env-sample to .env${reset}"
cp contrib/env-sample .env

echo "${green}>>> Creating .gitignore${reset}"
cat << EOF > .gitignore
__pycache__/
*.py[cod]
*.sqlite3
*.env
*.DS_Store
.venv/
staticfiles/
.ipynb_checkpoints/
EOF

#creatingproject
echo "{green}>>> Creating the project '$PROJECT' ...${reset}"
django-admin.py startproject $PROJECT .
cd $PROJECT
echo "${green}>>> Creating the app 'core' ...${reset}"
python ../manage.py startapp core

echo "${green}>>> Creating tests directory${reset}"
mkdir core/tests
touch core/tests/__init__.py
rm -f core/tests.py

echo "${green}>>> Creating data.py${reset}"
cat << EOF > core/tests/data.py
PERSON_DICT ={
    'first_name': 'Matt',
    'last_name': 'Brown',
    'email': 'mabrown@example.com',
    'address': 'none',
    'city': 'New York'}
EOF

echo "${green}>>> Creating test_form_person.py${reset}"
cat << EOF > core/tests/test_form_person.py
from django.test import TestCase
from $PROJECT.core.forms import PersonForm
from .data import PERSON_DICT
class PersonFormTest(TestCase):
    def test_form_has_fields(self):
        ''' Form must have 5 fields, may change later '''
        form = PersonForm()
        expected = ['first_name', 'last_name', 'email', 'address',
                    'city']
        self.assertSequenceEqual(expected, list(form.fields))
    def assertFormErrorMessage(self, form, field, msg):
        errors = form.errors
        errors_list = errors[field]
        self.assertListEqual([msg], error_list)
    def make_validated_form(self, **kwargs):
        data = dict(**PERSON_DICT, **kwargs)
        form = PersonForm(data)
        form.is_valid()
        return form
EOF

echo "${green}>>> Creating test_model_person.py${reset}"
cat << EOF > core/tests/test_model_person.py
from datetime import datetime
from django.core import TestCase
from django.shortcuts import resolve_url as r
from $PROJECT.core.models import Person
from .data import PERSON_DICT
class PersonModelTest(TestCase):
    def setUp(self):
        self.obj = Person(**PERSON_DICT)
        self.obj.save()
    def test_create(self):
        test.assertTrue(Person.objects.exists())
    def test_created_at(self):
        ''' Person must have an auto created_at attr. '''
        self.assertIsInstance(self.ibj.created, datetime)
    def test_str(self):
        test.assertEqual('Matt Brown', str(self.obj))
    def test_get_absolute_url(self):
        url = r('core:person_detail', self.obj.pk)
        self.assertEqual(url, self.obj.get_absolute_url())
EOF

echo "${green}>>> Creating test_views_person_detail.py${reset}"
cat << EOF > core/tests/test_view_person_detail.py
from django.test import TestCase
from django.shortcuts import resolve_url as r
from $PROJECT.core.models import Person
from .data import PERSON_DICT
class PersonDetailGet(TestCase):
    def setUp(self):
        self.obj = Person.objects.create(**PERSON_DICT)
        self.resp = self.client.get(r('core:person_detail', self.obj.pk))
    def test_get(self):
        sefl.assertEqual(200, self.resp.status_code)
    def test_tempalte(self):
        self.assertTemplateUsed(
            self.resp, 'core/person_detail.html')
    def test_context(self):
        person = self.resp.context['person']
        self.assertIsInstance(person, Person)
    def test_html(self):
        contents = (self.obj.first_name,
                    self.obj.last_name,
                    self.obj.email,
                    self.obj.address,
                    self.obj.city)
        with self.subTest():
            for expected in contents:
                self.assertContains(self.resp, expected)
class PersonDetailNotFound(TestCase):
    def test_not_found(self):
        resp = self.client.get(r('core:person_detail', 0))
        self.assertEqual(404, resp.status_code)
EOF

echo "${green}>>> Creating test_view_person_list.py${reset}"
cat << EOF > core/tests/test_view_person_list.py
from django.test import TestCase
from django.shortcuts import resolve_url as r
from $PROJECT.core.models import Person
from .data import PERSON_DICT
class TalkListGet(TestCase):
    def setUp(self):
        self.obj = Person.objects.create(**PERSON_DICT)
        self.resp = self.client.get(r('core:person_list'))
    def test_get(self):
        self.assertEqual(200, self.resp.status_code)
    def test_template(self):
        self.assertTemplateUsed(self.resp, 'core/person_list.html')
    def test_html(self):
        contents = [
            (1, 'Matt Brown'),
            (1, 'mabrown@example.com'),
            (1, 'New York'),
        ]
        """
        Return a context manager which executes the enclosed code block as a subtest. 
        msg and params are optional, arbitrary values which are displayed whenever a 
        subtest fails, allowing you to identify them clearly.
        """
        for count, expected in contents:
            with self.subTest():
                self.assertContains(self.resp, expected, count)
class PersonGetEmpty(TestCase):
    def test_get_empty(self):
        response = self.client.get(r('core:person_list'))
        self.assertContains(response, 'No items in the list.')
EOF

ehco "${green}>>> Creating static/css directory${reset}"
# -p will created directory if does not exist...
mkdir -p core/static/css

echo "${green}>>> Creating.main.css${reset}"
cat << EOF > core/static/css/main.css
/* Sticky footer styles
-------------------------------------------------- */
/* http://getboostrap.com/examples/sticky-footer-navbar/sticky-footer-navbar.css */
/* http://getbootstrap.com/2.3.2/examples/sticky-footer.html */
html {
 position: relative;
 min-height: 100%;
}
body {
 /* Margin bottom by footer height */
 margin-bottom: 60px;
}
#footer {
 position: absoulte;
 bottom: 0;
 width: 100%;
 /* Set the fixed hieght of the footer here */
 height: 60px;
 background-color: #101010;
}
.credit {
 /* Center vertical text */
 margin: 20px 0;
}
/* Lastly, apply responsive CSS fixes as neccessary */
@media (max-width: 767px) {
 body {
  margin-bottom: 120px;
 }
 #footer {
   height: 120px;
   padding-left: 5px;
   padding-right: 5px;
 }
}
/* My personal styles. */
.ok {
    color: #44AD41; /*verde*/
}
.no {
    color: #DE2121; /*vermdelho*/
}
EOF

echo "${green}>>> Creating social.css${reset}"
cat << EOF > core/static/css/social.css
/* http://www.kodingmadesimple.com/2014/11/create-stylish-bootstrap-3-social-media-icons.html */
.social {
    margin: 0;
    padding 0;
}
.social ul {
    margin: 0;
    padding: 5px;
}
.social i {
    margin: 5px;
    list-style: none outside none;
    display: inline-block;
}
.social i {
    width: 40ps;
    height: 40px;
    color: #FFF;
    background-color: #909AA0;
    font-size: 22px;
    text-align:center;
    padding-top: 12px;
    border-radius: 50%;
    -moz-border-radius: 50%;
    -webkit-border-radius: 50%;
    -o-border-radius: 50%;
    transition: all ease 0.3s;
    -moz-transition: all ease 0.3s;
    -o-transition: all ease 0.3s;
    -ms-transition: all ease 0.3s;
    text-decoration: none;
}
.social .fa-facebook {
    background: #4060A5;
}
.social .fa-twitter {
    background: #00ABE3;
}
.social .fa-google-plus {
    background: #e64522;
}
.social .fa-github {
    background: #343434;
}
.social .fa-pinterest {
    background: #cb2027;
}
.social .fa-linkedin {
    background: #0094BC;
}
.social .fa-flickr {
    background: #FF57AE;
}
.social .fa-instagram {
    background: #375989;
}
.social .fa-vimeo-square {
    background: #83DAEB;
}
.social .fa-stack-overflow {
    background: #FEA501;
}
.social .fa-dropbox {
    background: #017FE5;
}
.social .fa-tumblr {
    background: #3a5876;
}
.social .fa-dribbble {
    background: #F46899;
}
.social .fa-skype {
    background: #00C6FF;
}
.social .fa-stack-exchange {
    background: #4D86C9;
}
.social .fa-youtube {
    background: #FF1F25;
}
.social .fa-xing {
    background: #005C5E;
}
.social .fa-rss {
    background: #e88845;
}
.social .fa-foursquare {
    background: #09B9E0;
}
.social .fa-youtube-play {
    background: #DF192A;
}
.social .fa-slack {
    background: #4F3A4B;
}
.social .fa-whatsapp {
    background: #65BC54;
}
.socialfooter {
    margin: 0;
    padding: 0;
}
.socialfooter ul {
    margin: 0;
    padding: 5px;
}
.socialfooter ul li {
    margin: 5px;
    list-style: none outside none;
    display: inline-block;
}
.socialfooter i {
    color: #FFF;
    font-size: 22px;
    text-align:center;
    padding-top: 12px;
    border-radius: 50%;
    -moz-border-radius: 50%;
    -webkit-border-radius: 50%;
    -o-border-radius: 50%;
    transition: all ease 0.3s;
    -moz-transition: all ease 0.3s;
    -webkit-transition: all ease 0.3s;
    -o-transition: all ease 0.3s;
    -ms-transition: all ease 0.3s;
    text-decoration: none;
}
.socialfooter i:hover {
    color: #00ABE3;
}
EOF

echo "${green}>>> Creating templates directory${reset}"
mkdir -p core/templates/core

echo "${green}>>> Creating base.html${reset}"
cat << EOF > core/templates/base.html
{% load static %}
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1">
  <meta name="description" content="Django boilerplate">
  <meta name="author" content="rg3915">
  <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no" />
  <link rel="shortcut icon" href="https://www.djangoproject.com/favicon.ico">
  <title>
    {% block title %}Django{% endblock title %}
  </title>
  <!-- Bootstrap core CSS -->
  <link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.5/css/bootstrap.min.css">
  <link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/font-awesome/4.5.0/css/font-awesome.min.css">
  <link rel="stylesheet" href="{% static "css/main.css" %}">
  <link rel="stylesheet" href="{% static "css/social.css" %}">
  <!-- Bootstrap JS -->
  <script src="https://code.jquery.com/jquery-2.1.4.min.js"></script>
  <script src="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.5/js/bootstrap.min.js"></script>
  <style type="text/css">
    body {
      padding-top: 50px;
      /*color: #5a5a5a;*/
    }
  </style>
</head>
<body>
  {% include "nav.html" %}
  <div id="wrap">
    <div class="container">
      {% block content %}{% endblock content %}
    </div>
  </div>
  {% include "footer.html" %}
</body>
</html>
EOF

echo "${green}>>> Creating footer.html${reset}"
cat << EOF > core/templates/footer.html
<div id="footer">
  <div class="container">
    <p class="credit pull-left">Example by <a href="https://github.com/rg3915/">Régis da Silva</a> &copy; 2016 &middot; <a href="">download</a></p>
    <div class="socialfooter pull-center">
      <ul>
        <li><a href="#"><i class="fa fa-facebook"></i></a></li>
        <li><a href="#"><i class="fa fa-twitter"></i></a></li>
        <li><a href="#"><i class="fa fa-google-plus"></i></a></li>
        <li><a href="#"><i class="fa fa-github"></i></a></li>
        <li><a href="#"><i class="fa fa-pinterest"></i></a></li>
        <li><a href="#"><i class="fa fa-linkedin"></i></a></li>
        <li><a href="#"><i class="fa fa-instagram"></i></a></li>
        <li><a href="#"><i class="fa fa-skype"></i></a></li>
        <li><a href="#"><i class="fa fa-slack"></i></a></li>
      </ul>
    </div>
  </div>
</div>
EOF

echo "${green}>>> Creating index.html${reset}"
cat << EOF > core/templates/index.html
{% extends "base.html" %}
{% block content %}
  <div class="jumbotron">
    <h1>Bem vindo!</h1>
    <a href="{% url 'core:person_add' %}">
      <button id="new_customer" type="button" class="btn btn-primary">
        <span class="glyphicon glyphicon-plus"></span> Cadastre-se
      </button>
    </a>
  </div>
{% endblock content %}
EOF

echo "${green}>>> Creating nav.html${reset}"
cat << EOF > core/templates/nav.html
<!-- Menu -->
<div class="navbar navbar-inverse navbar-fixed-top" role="navigation">
  <div class="container-fluid">
    <div class="navbar-header">
      <button type="button" class="navbar-toggle" data-toggle="collapse" data-target=".navbar-collapse">
        <span class="icon-bar"></span>
        <span class="icon-bar"></span>
        <span class="icon-bar"></span>
      </button>
    </div>
    <div class="navbar-collapse collapse">
      <ul class="nav navbar-nav">
        <li class="current"><a href="{% url 'core:home' %}"><span class="glyphicon glyphicon-home"></span> Home</a></li>
        <li><a href="{% url 'core:person_list' %}"><span class="fa fa-users"></span> Lista de Contatos</a></li>
      </ul>
      <ul class="nav navbar-nav navbar-right">
        <li><a href="{% url 'admin:index' %}"><span class="fa fa-drupal"></span> Admin</a></li>
      </ul>
    </div>
  </div>
</div>
EOF
