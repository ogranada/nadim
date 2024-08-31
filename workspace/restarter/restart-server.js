
const dotenv = require('dotenv');
const express = require('express');
const { normalize } = require('path');
const { spawn } = require('child_process');

function restartServer() {
  const restartCmd = normalize([process.cwd(), '..', 'restart.sh'].join('/'));
  const runCmd = normalize([process.cwd(), '..', 'run.sh'].join('/'));
  console.log(`Restarting server: bash ${restartCmd}`);
  const execution = spawn('/bin/bash', [restartCmd]);

  execution.stdout.on('data', (data) => {
    console.log(data.toString());
  });

  execution.stderr.on('data', (data) => {
    console.error(data.toString());
  });

  execution.on('exit', (code) => {
    console.log(`Child exited with code ${code}`);
    spawn('/bin/bash', [runCmd]);
    console.log(`Restart executed ${runCmd}`);
  }); 
}

const main = () => {
  dotenv.config();
  const TOKENS = (process?.env?.TOKENS || '').split(';');
  const PORT = process?.env?.MONITOR_PORT || 8484;
  const server = express();
  server.use(express.json());

  server.post('/actions/restart', (req, res) => {
    const { token } = req.body;
    if (TOKENS.includes(token)) {
      restartServer();
      res.status(202).json({
        message: 'restarting',
        status: 202,
      });
      return;
    }
    res.status(401).json({
      message: 'invalid',
      status: 401,
    });
  });

  server.get('*', (req, res) => {
    res.status(404).send(`<h1>Not Found</h1>`);
  });

  server.use((err, req, res, next) => {
    res.status(404).send(`<h1>Not Found</h1>`);
  });

  server.listen(PORT, () => {
    console.log(`Ready at ${PORT}.`);
  });
};

main();
