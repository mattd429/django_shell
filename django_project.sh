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
    <p class="credit pull-left">Example by <a href="https://github.com/mattd429/">Matt Brown</a> &copy; 2016 &middot; <a href="">download</a></p>
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

echo "${green}>>> Creating pagination.html${reset}"
cat << EOF > core/templates/pagination.html
<!-- pagination -->
<div class="row text-center">
  <div class="col-lg-12">
    <ul class="pagination">
      {% if page_obj.has_previous %}
        <li><a href="?page={{ page_obj.previous_page_number }}">&laquo;</a></li>
      {% endif %}
      {% for pg in page_obj.paginator.page_range %}
        {% if page_obj.number == pg %}
          <li class="active"><a href="?page={{ pg }}">{{ pg }}</a></li>
        {% else %}
          <li><a href="?page={{ pg }}">{{ pg }}</a></li>
        {% endif %}
      {% endfor %}
      {% if page_obj.has_next %}
        <li><a href="?page={{ page_obj.next_page_number }}">&raquo;</a></li>
      {% endif %}
    </ul>
  </div>
</div>
<!-- https://www.technovelty.org/web/skipping-pages-with-djangocorepaginator.html -->
EOF

echo "${green}>>> Creating person_detail.html${reset}"
cat << EOF > core/templates/core/person_detail.html
{% extends "base.html" %}
{% load static %}
{% block title %}Person Detail{% endblock title %}
{% block content %}
<ul class="breadcrumb">
  <li><a href="{% url 'core:home' %}">Home</a> <span class="divider"></span></li>
  <li><a href="{% url 'core:person_list' %}">Contatos</a> <span class="divider"></span></li>
  <li class="active">{{ object.full_name }}</li>
</ul>
<div class="col-lg-8">
  <div class="col-md-2 column">
    <img src="https://cdn4.iconfinder.com/data/icons/ionicons/512/icon-person-128.png" class="img-square" style="height: 100px;" />
  </div>
    <div class="col-md-offset-3 column">
    <h1>{{ object.full_name }}</h1>
    {% if object.email %}
      <h4><span class="glyphicon glyphicon-envelope"></span><a href="#"> {{ object.email }}</a></h4>
    {% endif %}
        <div class="social">
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
  </br>
  <table class="table table-user-information">
    <tbody>
      {% if object.phone_set.all %}
        {% for phone in object.phone_set.all %}
          <tr>
            <th class="col-md-3 text-right"><span class="glyphicon glyphicon-earphone"></span></th>
            <td>{{ phone.phone }} <i class="fa fa-whatsapp ok"></i> {{ phone.get_phone_type_display }}</td>
          </tr>
        {% endfor %}
      {% else %}
        <tr>
          <th class="col-md-3 text-right"><span class="glyphicon glyphicon-earphone"></span></th>
          <td>---</td>
        </tr>
      {% endif %}
      {% if object.address %}
        <tr>
          <th class="col-md-3 text-right"><span class="glyphicon glyphicon-map-marker"></span></th>
          <td>{{ object.address }}
            {% if object.complement %} - {{ object.complement }}{% endif %}
            {% if object.district %} - {{ object.district }}{% endif %}
          </td>
        </tr>
        <tr>
          <th class="col-md-3 text-right"></th>
          <td>
            {% if object.city %}{{ object.city }}{% endif %}
            {% if object.uf %} - {{ object.uf }}{% endif %}
            {% if object.cep %} - {{ object.cep }}{% endif %}
          </td>
        </tr>
      {% endif %}
            <tr>
        <th class="col-md-3 text-right">Bloqueado</th>
          <td><span class="glyphicon {{ object.blocked|yesno:'glyphicon-ok-sign ok,glyphicon-minus-sign no'}}"></span></td>
      </tr>
    </tbody>
  </table>
  <!-- edit -->
    <a href="{% url 'core:person_edit' person.pk %}">
      <button id="edit_person" type="button" class="btn btn-success">
          <span class="fa fa-pencil"></span> Editar
      </button>
  </a>
  <!-- delete with modal -->
  <button type="button" class="btn btn-danger" data-toggle="modal" data-target="#myModal">
      <span class="fa fa-times"></span> Excluir
  </button>
</div>
<!-- Modal -->
<div class="modal fade" id="myModal" tabindex="-1" role="dialog" aria-labelledby="myModalLabel">
  <div class="modal-dialog" role="document">
    <div class="modal-content">
      <div class="modal-header">
        <button type="button" class="close" data-dismiss="modal" aria-label="Close"><span aria-hidden="true">&times;</span></button>
        <h4 class="modal-title" id="myModalLabel">Confirmar</h4>
      </div>
        <form action="{% url 'core:person_delete' person.id %}" method="POST">
      <div class="modal-body">
          {% csrf_token %}
          Deseja mesmo deletar "{{ object }}"?
      </div>
      <div class="modal-footer">
        <button type="button" class="btn btn-default" data-dismiss="modal">Fechar</button>
        <input type="submit" class="btn btn-danger" value="Deletar" />
      </div>
        </form>
    </div>
  </div>
</div>
{% endblock content %}
EOF

echo "${green}>>> Creating person_form.html${reset}"
cat << EOF > core/templates/core/person_form.html
{% extends "base.html" %}
{% load widget_tweaks %}
{% block title %}Person Form{% endblock title %}
{% block content %}
<div class="page-header">
    <h2>New Contact</h2>
</div>
<form class="form-horizontal" action="." method="POST">
    {% csrf_token %}
    {{ form.non_fields_errors }}
    <div class="form-group">
        <label class="control-label col-sm-2 col-lg-2">
            {{ form.first_name.label }}
        </label>
        <div class="col-sm-4 col-lg-4">
            {{ form.first_name|attr:"class:form-control" }} {{ form.first_name.errors }}
        </div>
    </div>
    <div class="form-group">
        <label class="control-label col-sm-2 col-lg-2">
            {{ form.last_name.label }}
        </label>
        <div class="col-sm-4 col-lg-4">
            {{ form.last_name|attr:"class:form-control" }} {{ form.last_name.errors }}
        </div>
    </div>
    <div class="form-group">
        <label class="control-label col-sm-2 col-lg-2">
            {{ form.email.label }}
        </label>
        <div class="col-sm-4 col-lg-4">
            {{ form.email|attr:"class:form-control" }} {{ form.email.errors }}
        </div>
    </div>
    <div class="form-group">
        <label class="control-label col-sm-2 col-lg-2">
            {{ form.address.label }}
        </label>
        <div class="col-sm-4 col-lg-4">
            {{ form.address|attr:"class:form-control" }} {{ form.address.errors }}
        </div>
    </div>
    <div class="form-group">
        <label class="control-label col-sm-2 col-lg-2">
            {{ form.complement.label }}
        </label>
        <div class="col-sm-4 col-lg-4">
            {{ form.complement|attr:"class:form-control" }} {{ form.complement.errors }}
        </div>
    </div>
    <div class="form-group">
        <label class="control-label col-sm-2 col-lg-2">
            {{ form.district.label }}
        </label>
        <div class="col-sm-4 col-lg-4">
            {{ form.district|attr:"class:form-control" }} {{ form.district.errors }}
        </div>
    </div>
    <div class="form-group">
        <label class="control-label col-sm-2 col-lg-2">
            {{ form.city.label }}
        </label>
        <div class="col-sm-4 col-lg-4">
            {{ form.city|attr:"class:form-control" }} {{ form.city.errors }}
        </div>
    </div>
    <div class="form-group">
        <label class="control-label col-sm-2 col-lg-2">
            {{ form.uf.label }}
        </label>
        <div class="col-sm-4 col-lg-4">
            {{ form.uf|attr:"class:form-control" }} {{ form.uf.errors }}
        </div>
    </div>
    <div class="form-group">
        <label class="control-label col-sm-2 col-lg-2">
            {{ form.cep.label }}
        </label>
        <div class="col-sm-4 col-lg-4">
            {{ form.cep|attr:"class:form-control" }} {{ form.cep.errors }}
        </div>
    </div>
    <div class="form-group">
        <label class="control-label col-sm-2 col-lg-2">
            {{ form.blocked.label }}
        </label>
        <div class="col-sm-4 col-lg-4">
            {{ form.blocked }} {{ form.blocked.errors }}
        </div>
    </div>
        <div class="form-group">
      <div class="col-sm-2 col-sm-offset-2">
        <button type="submit" class="btn btn-primary">Salvar</button>
      </div>
    </div>
</form>
{% endblock content %}
EOF

echo "{green}>>> Creating person_list.html${reset}"
cat << EOF > core/templates/core/person_list.html
{% extends 'base.html' %}
{% block title %}Contracts{% endblock title %}
{% block content %}
<form class="navbar-form navbar-right" action="." method="get">
    <!-- add -->
    <a href="{% url 'core:person_add' %}">
        <button id="new" type="button" class="btn btn-primary">
            <span class="glyphicon glyphicon-plus"></span> Adicionar
        </button>
    </a>
    <!-- search form -->
    <div class="form-group">
      <input id="search_box" name="search_box" type="text" placeholder="Localizar..." class="form-control">
      <button type="submit" class="btn btn-success form-control"><span class="glyphicon glyphicon-search"></span></button>
  </div>
</form>
<div class="page-header">
<h2><h2><i class="fa fa-user"></i> List of Contracts</h2>
</div>
<div>
{% if person_list %}
  <table class="table table-striped">
    <thead>
      <tr>
        <th>Nome</th>
        <th>Email</th>
        <th>Telefone</th>
        <th>UF</th>
      </tr>
    </thead>
    <tbody>
    {% for person in person_list %}
      <tr>
        <td><a href="{{ person.get_absolute_url }}">{{ person.full_name }}</a></td>
        <td>{{ person.email }}</td>
        {% if person.phone_set.first %}
          <td>{{ person.phone_set.first }} 
            {% if person.phone_set.count > 1 %}
              <a href="{{ person.get_absolute_url }}">+{{ person.phone_set.count|add:"-1" }}</a>
            {% endif %}
          </td>
        {% else %}
          <td>---</td>
        {% endif %}
        <td>{{ person.get_uf_display }}</td>
      </tr>
    {% endfor %}
    </tbody>
  </table>
  {% else %}
  <p class="alert alert-warning">No items in the list.</p>
{% endif %}
</div>
<hr>
<div>
<h4><b>Total:</b> {{ page_obj.paginator.count }} contract{{ page_obj.paginator.count|pluralize }}</h4>
</div>
{% include "pagination.html" %}
{% endblock content %}
EOF

# up one level
cd ..

# ************ Editing FILES ******************
echo "${green}>>> Refactor .env${reset}"
# find SECRET_KEY
grep "SECRET_KEY" $PROJECT/settings.py > .env
#replace = 
sed -i "s/ = /=/g" .env
# replace '
sed -i "s/'//g" .env
cat << EOF >> .env
DEBUG=True
ALLOWED_HOSTS=127.0.0.1, .localhost
EOF

echo "${green}>>> Editing settings.py${reset}"
# insert text in line below of string
sed -i "/import os/a\from decouple import config, Csv\nform dj_databse"
# remove everything except the 1st number characters in every line - See more at: http://www.theunixschool.com/2014/08/sed-examples-remove-delete-chars-from-line-file.html#sthash.h7FUerys.dpuf
sed -i "/SECRET_KEY/d" $PROJECT/settings.py
# insert text in line below of string
sed -i "/keep the secret/a\SECRET_KEY = config('SECRET_KEY')" $PROJECT/settings.py
# replace text
sed -i "s/DEBUG = True/DEBUG = config('DEBUG', default=False, cast=bool)/g" $PROJECT/settings.py
sed -i "s/ALLOWED_HOSTS\ =\ \[\]/ALLOWED_HOSTS = config('ALLOWED_HOSTS', default=[], cast=Csv())/g" $PROJECT/settings.py
# insert text in line below of string
sed -i "/django.contrib.staticfiles/a\    # thirty apps\n    'widget_tweaks',\n    'daterange_filter',\n    'django_extensions',\n    \# my apps\n    '$PROJECT.core'," $PROJECT/settings.py
# exclude lines
sed -i "/DATABASES/d" $PROJECT/settings.py
sed -i "/'default':/d" $PROJECT/settings.py
sed -i "/ENGINE/d" $PROJECT/settings.py
# exclude 3 lines
sed -i "/db.sqlite3/,+3d" $PROJECT/settings.py
# insert text after 'databases'
sed -i "/databases/a default_dburl = 'sqlite:///' + os.path.join(BASE_DIR, 'db.sqlite3')\nDATABASES = {\n    'default': config('DATABASE_URL', default=default_dburl, cast=dburl),\n}" $PROJECT/settings.py
# replace text
sed -i "s/en-us/pt-br/g" $PROJECT/settings.py
# replace text
sed -i "s/UTC/America\/Sao_Paulo/g" $PROJECT/settings.py
# insert text in line below of string
sed -i "/USE_TZ/a\\\nUSE_THOUSAND_SEPARATOR = True\n\nDECIMAL_SEPARATOR = ','" $PROJECT/settings.py
sed -i "/STATIC_URL/a\STATIC_ROOT = os.path.join(BASE_DIR, 'staticfiles')\n\nLOGIN_URL = '/admin/login/'" $PROJECT/settings.py

echo "${green}>>> Creating core/urls.py${reset}"
cat << EOF > $PROJECT/core/urls.py
from django.conf.urls import include, url
from $PROJECT.core import views as c
person_patterns = [
    url(r'^$', c.PersonList.as_view(), name='person_list'),
    url(r'^add/$', c.person_create, name='person_add'),
    url(r'^(?P<pk>\d+)/$', c.person_detail, name='person_detail'),
    url(r'^(?P<pk>\d+)/edit/$', c.person_update, name='person_edit'),
    url(r'^(?P<pk>\d+)/delete/$', c.person_delete, name='person_delete'),
]
urlpatterns = [
    url(r'^$', c.home, name='home'),
    url(r'^person/', include(person_patterns)),
]
EOF

echo "${green}>>> Editing urls.py${reset}"
cat << EOF > $PROJECT/urls.py
from django.conf.urls import include, url
from django.contrib import admin
urlpatterns = [
    url(r'', include('$PROJECT.core.urls', namespace='core')),
    url(r'^admin/', admin.site.urls),
]
EOF

echo "${green}>>> Editing admin.py${reset}"
cat << EOF > $PROJECT/core/admin.py
from daterange_filter.filter import DateRangeFilter
from django.contrib import admin
from .models import Person, Phone
from .forms import PersonForm
class PhoneInline(admin.TabularInline):
    model = Phone
    extra = 1
@admin.register(Person)
class PersonAdmin(admin.ModelAdmin):
    inlines = [PhoneInline]
    list_display = ('__str__', 'email', 'phone', 'uf', 'created', 'blocked')
    date_hierarchy = 'created'
    search_fields = ('first_name', 'last_name', 'email')
    list_filter = (
        # 'uf',
        ('created', DateRangeFilter),
    )
    form = PersonForm
    def phone(self, obj):
        return obj.phone_set.first()
    phone.short_description = 'telefone'
EOF

echo "${green}>>> Creating forms.py${reset}"
cat << EOF > $PROJECT/core/forms.py
from django import forms
from .models import Person
class PersonForm(forms.ModelForm):
    class Meta:
        model = Person
        fields = ['first_name', 'last_name', 'email', 'address',
                  'complement', 'district', 'city', 'uf', 'cep', 'blocked']
EOF

echo "${green}>>> Creating mixins.py${reset}"
cat << EOF > $PROJECT/core/mixins.py
from django.db.models import Q
class NameSearchMixin(object):
    def get_queryset(self):
        queryset = super(NameSearchMixin, self).get_queryset()
        q = self.request.GET.get('search_box')
        if q:
            return queryset.filter(
                Q(first_name__icontains=q) |
                Q(last_name__icontains=q) |
                Q(email__icontains=q))
        return queryset
EOF

echo "${green}>>> Editing models.py${reset}"
cat << EOF > $PROJECT/core/models.py
from django.db import models
from django.shortcuts import resolve_url as r
from localflavor.br.br_states import STATE_CHOICES
PHONE_TYPE = (
    ('pri', 'principal'),
    ('com', 'comercial'),
    ('res', 'residencial'),
    ('cel', 'celular'),
    ('cl', 'Claro'),
    ('oi', 'Oi'),
    ('t', 'Tim'),
    ('v', 'Vivo'),
    ('n', 'Nextel'),
    ('fax', 'fax'),
    ('o', 'outros'),
)
class TimeStampedModel(models.Model):
    created = models.DateTimeField('criado em', auto_now_add=True, auto_now=False)
    modified = models.DateTimeField('modificado em', auto_now_add=False, auto_now=True)
    class Meta:
        abstract = True
class Address(models.Model):
    address = models.CharField(u'endereço', max_length=100, blank=True)
    complement = models.CharField('complemento', max_length=100, blank=True)
    district = models.CharField('bairro', max_length=100, blank=True)
    city = models.CharField('cidade', max_length=100, blank=True)
    uf = models.CharField('UF', max_length=2, choices=STATE_CHOICES, blank=True)
    cep = models.CharField('CEP', max_length=9, blank=True)
    class Meta:
        abstract = True
class Person(TimeStampedModel, Address):
    first_name = models.CharField('nome', max_length=50)
    last_name = models.CharField('sobrenome', max_length=50, null=True, blank=True)
    email = models.EmailField(null=True, blank=True)
    blocked = models.BooleanField('bloqueado', default=False)
    class Meta:
        ordering = ['first_name']
        verbose_name = 'contato'
        verbose_name_plural = 'contatos'
    def __str__(self):
        return ' '.join(filter(None, [self.first_name, self.last_name]))
    full_name = property(__str__)
    def get_absolute_url(self):
        return r('core:person_detail', pk=self.pk)
class Phone(models.Model):
    phone = models.CharField('telefone', max_length=20, blank=True)
    person = models.ForeignKey('Person')
    phone_type = models.CharField('tipo', max_length=3, choices=PHONE_TYPE, default='pri')
    def __str__(self):
        return self.phone
EOF

echo "${green}>>> Editing views.py${reset}"
cat << EOF > $PROJECT/core/views.py
from django.shortcuts import render
from django.core.urlresolvers import reverse_lazy as r
from django.views.generic import CreateView, ListView, DetailView
from django.views.generic import UpdateView, DeleteView
from .mixins import NameSearchMixin
from .models import Person
from .forms import PersonForm
def home(request):
    return render(request, 'index.html')
class PersonList(NameSearchMixin, ListView):
    model = Person
    paginate_by = 5
person_detail = DetailView.as_view(model=Person)
person_create = CreateView.as_view(model=Person, form_class=PersonForm)
person_update = UpdateView.as_view(model=Person, form_class=PersonForm)
person_delete = DeleteView.as_view(model=Person, success_url=r('core:person_list'))
EOF


echo "${green}>>> Creating shell_person.py${reset}"
mkdir shell
cat << EOF > shell/shell_person.py
import string
import random
import csv
from $PROJECT.core.models import Person, Phone
PHONE_TYPE = ('pri', 'com', 'res', 'cel')
person_list = []
''' Read person.csv '''
with open('fix/person.csv', 'r') as f:
    r = csv.DictReader(f)
    for dct in r:
        person_list.append(dct)
    f.close()
''' Insert Persons '''
obj = [Person(**person) for person in person_list]
Person.objects.bulk_create(obj)
def gen_phone():
    digits_ = str(''.join(random.choice(string.digits) for i in range(11)))
    return '{} 9{}-{}'.format(digits_[:2], digits_[3:7], digits_[7:])
''' Insert Phones '''
persons = Person.objects.all()
for person in persons:
    for i in range(1, random.randint(1, 5)):
        Phone.objects.create(
            person=person,
            phone=gen_phone(),
            phone_type=random.choice(PHONE_TYPE))
# Done
EOF

echo "${green}>>> Creating person.csv${reset}"
mkdir fix
cat << EOF > fix/person.csv
first_name,last_name,email,address,complement,district,city,uf,cep
Adrian,Holovaty,holovaty@example.com,"Av. Ulisses Reis de Matos, 100",1º andar,Morumbi,São Paulo,SP,00568-602
Alan,Turing,turing@example.com,"Av Pedroso de Morais, 1552",,Pinheiros,São Paulo,SP,05420-002
Audrey,Roy Greenfeld,audrey.greenfeld@example.com,"Av 23 de Maio, 3041",,Vila Mariana,São Paulo,SP,04008-090
Daniel,Roy Greenfeld,danny.greenfeld@example.com,"Rua Padre Machado, 68",10º andar,Vila Mariana,São Paulo,SP,04127-001
Donald,Knuth,knuth@example.com,"Rua Miguel, 337",casa 2,Jardim Novo Pantanal,São Paulo,SP,04472-060
Grace,Hopper,hopper@example.com,"Rua Colômbia, 659",,Jardim América,São Paulo,SP,01438-001
Guido,Van Rossum,vanrossum@example.com,"Av. Pacaembú, 380",apto 501,Barra Funda,São Paulo,SP,01155-000
Jacob,Kaplan Moss,kaplanmoss@example.com,"Av. Indianópolis, 100",3º andar,Indianópolis,São Paulo,SP,04062-000
Peter,Baumgartner,baumgartner@example.com,"Rua Colômbia, 810",,Jardim América,São Paulo,SP,01438-001
Simon,Willison,willison@example.com,"Av. Moreira Guimarães, 367",fundos,Moema,São Paulo,SP,04074-030
EOF

echo "${green}>>> Creating selenium_person.py${reset}"
mkdir selenium
cat << EOF > selenium/selenium_person.py
import time
import csv
from random import randint
from selenium import webdriver
page = webdriver.Firefox()
page.maximize_window()
time.sleep(0.5)
page.get('http://localhost:8000/person/add/')
person_list = []
''' Read person.csv '''
with open('fix/person.csv', 'r') as f:
    r = csv.DictReader(f)
    for dct in r:
        person_list.append(dct)
    f.close()
INDEX = randint(0, 9)
fields = [
    ['id_first_name', person_list[INDEX]['first_name']],
    ['id_last_name', person_list[INDEX]['last_name']],
    ['id_email', person_list[INDEX]['email']],
    ['id_address', person_list[INDEX]['address']],
    ['id_complement', person_list[INDEX]['complement']],
    ['id_district', person_list[INDEX]['district']],
    ['id_city', person_list[INDEX]['city']],
    ['id_uf', person_list[INDEX]['city']],  # deixa city mesmo
    ['id_cep', person_list[INDEX]['cep']],
]
for field in fields:
    search = page.find_element_by_id(field[0])
    search.send_keys(field[1])
# button = page.find_element_by_id('id_submit')
button = page.find_element_by_class_name('btn-primary')
button.click()
page.quit()
EOF

echo "${green}>>> Creating Makefile${reset}"
cat << EOF > Makefile
shell_person:
tabpython manage.py shell < shell/shell_person.py
selenium_person:
tabpython selenium/selenium_person.py
createuser:
tabpython manage.py createsuperuser --username='admin' --email=''
backup:
tabpython manage.py dumpdata core --format=json --indent=2 > fixtures.json
load:
tabpython manage.py loaddata fixtures.json
EOF

sed -i "s/tab/\t/g" Makefile

# migrate
python manage.py makemigrations
python manage.py migrate

echo "${green}>>> Running tests${reset}"
python manage.py test

echo "${green}>>> Populating database...${reset}"
python manage.py shell < shell/shell_person.py

echo "${green}>>> Backup${reset}"
python manage.py dumpdata core --format=json --indent=2 > fixtures.json

echo -n "Create superuser? (y/N) "
read answer
if [ "$answer" == "y" ]; then
    echo "${green}>>> Creating a 'admin' user ...${reset}"
    echo "${green}>>> The password must contain at least 8 characters.${reset}"
    echo "${green}>>> Password suggestions: demodemo${reset}"
    python manage.py createsuperuser --username='admin' --email=''
fi

echo "${green}>>> Running tests again${reset}"
python manage.py test

echo "${green}>>> See the Makefile${reset}"
cat Makefile

echo "${red}>>> Important: Dont add .env in your public repository.${reset}"
echo "${red}>>> KEEP YOUR SECRET_KEY AND PASSWORDS IN SECRET!!!\n${reset}"
echo "${green}>>> Done${reset}"
# https://www.gnu.org/software/sed/manual/sed.html

    
