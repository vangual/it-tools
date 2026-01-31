<script setup lang="ts">
import markdownit from 'markdown-it';
import markdownitSanitizer from 'markdown-it-sanitizer';
import markdownitSup from 'markdown-it-sup';
import markdownitSub from 'markdown-it-sub';
import markdownitMark from 'markdown-it-mark';
import { align } from '@mdit/plugin-align';
import TextareaCopyable from '@/components/TextareaCopyable.vue';

const handleHtml = ref(true);
const sanitize = ref(true);
const handleAlign = ref(false);
const handleSubSup = ref(false);
const handleMark = ref(false);

const inputMarkdown = ref('');
const outputHtml = computed(() => {
  let md = markdownit({ html: handleHtml.value });
  if (handleHtml.value && sanitize.value) {
    md = md.use(markdownitSanitizer);
  }
  if (handleAlign.value) {
    md = md.use(align as never);
  }
  if (handleSubSup.value) {
    md = md.use(markdownitSub).use(markdownitSup);
  }
  if (handleMark.value) {
    md = md.use(markdownitMark);
  }
  return md.render(inputMarkdown.value);
});

function printHtml() {
  const w = window.open();
  if (w === null) {
    return;
  }
  w.document.body.innerHTML = outputHtml.value;
  w.print();
}
</script>

<template>
  <div>
    <c-input-text
      v-model:value="inputMarkdown"
      multiline raw-text
      placeholder="Your Markdown content..."
      rows="8"
      autofocus
      label="Your Markdown to convert:"
    />

    <n-space justify="center" gap-1>
      <n-checkbox v-model:checked="handleHtml">
        Allow HTML tags
      </n-checkbox>
      <n-checkbox v-model:checked="sanitize" :disabled="!handleHtml">
        Sanitize HTML
      </n-checkbox>
      <n-checkbox v-model:checked="handleSubSup">
        Allow Superscript (^) and Subscript (~)
      </n-checkbox>
      <n-checkbox v-model:checked="handleAlign">
        Handle <n-a href="https://mdit-plugins.github.io/align.html#syntax" target="blank">
          alignment
        </n-a>
      </n-checkbox>
      <n-checkbox v-model:checked="handleMark">
        Allow Mark (==)
      </n-checkbox>
    </n-space>

    <n-divider />

    <n-form-item label="Output HTML:">
      <TextareaCopyable :value="outputHtml" :word-wrap="true" language="html" />
    </n-form-item>

    <div flex justify-center>
      <n-button @click="printHtml">
        Print (ie, use a PDF Printer to get a PDF file)
      </n-button>
    </div>
  </div>
</template>
