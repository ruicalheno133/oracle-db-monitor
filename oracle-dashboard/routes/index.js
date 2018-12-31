var express = require('express');
var router = express.Router();
var axios = require('axios');

/* GET dashboard main page */
router.get('/', function(req, res) {
  axios.get('http://localhost:8080/ords/manager/cur_status')
  .then(dados => {
    res.render('index', {status: dados.data.items[0]})
  })
  .catch(err => {
    res.jsonp(err)
    res.end()
  })
});

/* GET status */
router.get('/status', function(req, res) {
    axios.get('http://localhost:8080/ords/manager/status?q={"$orderby":{"status_key":"DESC"}}&limit=1')
         .then(dados => {
            res.render('status', {status: dados.data.items  })
         })
         .catch(err => {
           res.jsonp(err)
           res.end()
         })
});

/* GET Current users data */
router.get('/users', function(req, res) {
  axios.get('http://localhost:8080/ords/manager/cur_user')
  .then(dados => {
    res.render('users', {users: dados.data.items})
  })
  .catch(err => {
    res.jsonp(err)
    res.end()
  })
});

/* GET Current and Specific users data */
router.get('/users/:id', function(req, res) {
  axios.get(`http://localhost:8080/ords/manager/cur_user?q={"user_id": ${req.params.id}}`)
  .then(dados => {
    res.render('user', {user: dados.data.items[0]})
  })
  .catch(err => {
    res.jsonp(err)
    res.end()
  })
});

/* GET Current tablespaces data */
router.get('/tablespaces', function(req, res) {
  axios.get('http://localhost:8080/ords/manager/cur_tablespace')
  .then(dados => {
    res.render('tablespaces', {tablespaces: dados.data.items})
  })
  .catch(err => {
    res.jsonp(err)
    res.end()
  })
});

/* GET Current and Specific tablespace data */
router.get('/tablespaces/:id', function(req, res) {
  axios.get('http://localhost:8080/ords/manager/cur_user_tablespace/?q={"tablespace_id":' + req.params.id + '}')
  .then(dados => {
    res.render('tablespace', {tablespace: dados.data.items[0]})
  })
  .catch(err => {
    res.jsonp(err)
    res.end()
  })
});

module.exports = router;
