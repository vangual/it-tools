<script setup lang="ts">
import { formatContent } from 'nginx-config-formatter';
import type { UseValidationRule } from '@/composable/validation';
import { withDefaultOnError } from '@/utils/defaults';

const defaultValue = `server {
listen 80 default_server;
listen [::]:80 default_server; 
root /var/www/html;  
index index.html; 
server_name _;  
location / {
try_files $uri $uri/ =404;
}
location /api/ {
proxy_pass http://localhost:8080/;
proxy_http_version 1.1;
proxy_set_header Upgrade $http_upgrade;
proxy_set_header Connection 'upgrade';
proxy_set_header Host $host;
proxy_cache_bypass $http_upgrade;
}  
}`;
function transformer(value: string) {
  return withDefaultOnError(() => formatContent(value, {
    indentStyle: 'space',
    dontJoinCurlyBracket: false,
    align: true,
    trailingBlankLines: false,
    extension: 'conf',
  }), '');
}

const rules: UseValidationRule<string>[] = [
  {
    validator: (v: string) => v === '' || formatContent(v),
    message: 'Provided Nginx config is not valid.',
  },
];
</script>

<template>
  <format-transformer
    input-label="Your Nginx config"
    :input-default="defaultValue"
    input-placeholder="Paste your Nginx config here..."
    output-label="Prettified Nginx config"
    :input-validation-rules="rules"
    :transformer="transformer"
  />
</template>
