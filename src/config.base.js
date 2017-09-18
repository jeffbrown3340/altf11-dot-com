import { default as dom } from './config.dom';

const config =
    (process.env.TARGET_PLATFORM === dom)[process.env.NODE_ENV || 'development'];

export default config;