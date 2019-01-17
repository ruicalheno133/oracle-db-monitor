var express = require('express');
var router = express.Router();
var axios = require('axios');

/* GET dashboard main page */
router.get('/', function(req, res) {
    res.render('dashboard');
});

/* GET status */
router.get('/status', function(req, res) {
    axios.get('http://localhost:8080/ords/manager/cur_status')
         .then(dados => {
            res.render('status', {status: dados.data.items[0]})
         })
         .catch(err => {
           res.jsonp(err)
           res.end()
         })
});

/* GET Current users data */
router.get('/users', function(req, res) {
  axios.get('http://localhost:8080/ords/manager/cur_user?limit=5000')
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
  axios.get('http://localhost:8080/ords/manager/cur_tablespace/?q={"tablespace_id":' + req.params.id + '}')
  .then(dados => {
    res.render('tablespace', {tablespace: dados.data.items[0]})
  })
  .catch(err => {
    res.jsonp(err)
    res.end()
  })
});

router.get('/datafiles', function(req,res){
  axios.get('http://localhost:8080/ords/manager/cur_datafile')
    .then(dados=>{
      res.render('datafiles',{datafiles :dados.data.items})
    })
    .catch(err => {
      res.jsonp(err)
      res.end()
    })
});

router.get('/datafiles/:id',function(req,res){
  axios.get('http://localhost:8080/ords/manager/cur_datafile/?q={"datafile_id":' + req.params.id+ '}')
    .then(dados => {
      res.render('datafile',{datafile: dados.data.items[0]})
    })
    .catch(err => {
      res.jsonp(err)
      res.end()
    })
});

router.get('/datafiles_pie/:id',function(req,res){
  axios.get('http://localhost:8080/ords/manager/cur_datafile/?q={"datafile_id":' + req.params.id+ '}')
    .then(dados => {
      res.jsonp({max_size: dados.data.items[0].max_size, size: dados.data.items[0].size})
      res.end();
    })
    .catch(err => {
      res.jsonp(err)
      res.end()
    })
});

router.get('/tablespace_datafiles/:id',function(req,res){
  axios.get('http://localhost:8080/ords/manager/cur_join_tablespace_datafile/?q={"tablespace_id":' + req.params.id+ '}')
    .then(dados => {
      res.render('tablespace_datafile',{datafiles: dados.data.items})
    })
    .catch(err => {
      res.jsonp(err)
      res.end()
    })
});

router.get('/tablespace_user/:id',function(req,res){
  axios.get('http://localhost:8080/ords/manager/cur_join_user_tablespace/?q={"tablespace_id":' + req.params.id + '}')
    .then(dados => {
      res.render('tablespace_user',{tu: dados.data.items})
    })
    .catch(err => {
      //res.jsonp(err)
      res.end()
    })
});

router.get('/roles', function(req,res){
  axios.get('http://localhost:8080/ords/manager/cur_role')
    .then(dados=>{
      res.render('roles',{roles :dados.data.items})
    })
    .catch(err => {
      res.jsonp(err)
      res.end()
    })
});

router.get('/roles/:id',function(req,res){
  axios.get('http://localhost:8080/ords/manager/cur_role/?q={"role_id":' + req.params.id+ '}')
    .then(dados => {
      res.render('role',{role: dados.data.items[0]})
    })
    .catch(err => {
      res.jsonp(err)
      res.end()
    })
});

router.get('/user_tablespace/:id',function(req,res){
  axios.get('http://localhost:8080/ords/manager/cur_join_user_tablespace/?q={"user_id":' + req.params.id + '}')
    .then(dados => {
      res.render('user_tablespace',{ut: dados.data.items})
    })
    .catch(err => {
      //res.jsonp(err)
      res.end()
    })
});

router.get('/user_role/:id',function(req,res){
  axios.get('http://localhost:8080/ords/manager/cur_join_user_role/?q={"user_id":' + req.params.id + '}')
    .then(dados => {
      res.render('user_role',{roles: dados.data.items})
    })
    .catch(err => {
      //res.jsonp(err)
      res.end()
    })
});

router.get('/role_user/:id',function(req,res){
  axios.get('http://localhost:8080/ords/manager/cur_join_user_role/?q={"role_id":' + req.params.id + '}')
    .then(dados => {
      res.render('role_user',{users: dados.data.items})
    })
    .catch(err => {
      //res.jsonp(err)
      res.end()
    })
});

router.get('/storage_pie',function(req,res){
  axios.get('http://localhost:8080/ords/manager/cur_size')
    .then(dados => {
      res.jsonp({max_size: dados.data.items[0].max_size, free_space: dados.data.items[0].free_space})
      res.end()
    })
    .catch(err => {
      res.jsonp(err)
      res.end()
    })
})

router.get('/dashboard_sessions_graph', function(req,res){
  axios.get('http://localhost:8080/ords/manager/cur_open_sessions')
    .then(dados => {
      var sessionsArr = new Array()
      var tstampArr = new Array()
      for(i = 0; i < dados.data.items.length; i++){
        sessionsArr[i] = dados.data.items[i].sessions
        tstampArr[i] = dados.data.items[i].tstamp
      }
      res.jsonp({sessions: sessionsArr, tstamps: tstampArr})
      res.end()
    })
    .catch(err => {
      res.jsonp(err)
      res.end()
    })
})

router.get('/sql_commands', function(req,res){
  axios.get('http://localhost:8080/ords/manager/cur_sql_commands')
    .then(dados => {
      res.jsonp({commands: dados.data.items})
      res.end()
    })
    .catch(err => {
      //res.jsonp(err)
      res.end()
    })
})

router.get('/dashboard_memory', function(req,res){
  axios.get('http://localhost:8080/ords/manager/cur_memory')
    .then(dados => {
      res.jsonp({free_space: dados.data.items[0].free_space, used_space: dados.data.items[0].used_space})
      res.end()
    })
    .catch(err => {
      res.end()
    })
})

router.get('/dashboard_cpu', function(req,res){
  axios.get('http://localhost:8080/ords/manager/cur_cpu')
    .then(dados => {
      res.jsonp({idle_time : dados.data.items[0].idle_time, busy_time: dados.data.items[0].busy_time, iowait_time: dados.data.items[0].iowait_time})
      res.end()
    })
    .catch(err => {
      res.end()
    })
})

module.exports = router;
