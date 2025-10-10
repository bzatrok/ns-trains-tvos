import 'dotenv/config';
import { Command } from 'commander';
import { render } from 'ink';
import React from 'react';
import App from './cli.js';

const program = new Command();

program
  .name('amberglass-cli')
  .description('NS train departure board for terminal')
  .version('0.1.0')
  .option('-s, --station <code>', 'Station code (e.g., AMS for Amsterdam)')
  .option('-r, --refresh <seconds>', 'Refresh interval in seconds', '10')
  .option('--no-animation', 'Disable split-flap animation')
  .parse();

const options = program.opts();

render(React.createElement(App, options));
