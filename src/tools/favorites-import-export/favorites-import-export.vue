<script setup lang="ts">
import type { Ref } from 'vue';
import JSON5 from 'json5';
import { useToolStore } from '../tools.store';
import { useQueryParamOrStorage } from '@/composable/queryParams';

const { t } = useI18n();

const replace = useQueryParamOrStorage({
  name: 'replace',
  storageName: 'favorites-import-export:replace',
  defaultValue: false,
});

const toolStore = useToolStore();
const inputType = ref<'file' | 'content'>('file');
const importContent = ref('');
const fileInput = ref() as Ref<File | null>;
const importInfosRaw = computedAsync(async () => {
  const file = fileInput.value;
  const content = importContent.value;
  try {
    if (inputType.value === 'file' && file) {
      const string_content = await readFileAsString(file);
      const parsed_import = JSON5.parse(string_content);
      return {
        tools: parsed_import,
        string: string_content,
      };
    }
    else {
      const parsed_import = JSON5.parse(content);
      return {
        tools: parsed_import,
        string: content,
      };
    }
  }
  catch (e: any) {
    return {
      error: e.toString(),
    };
  }
});

async function onUpload(file: File) {
  if (file) {
    fileInput.value = file;
  }
}

watch(importContent, (_, newValue) => {
  if (newValue !== '') {
    fileInput.value = null;
  }
});

function readFileAsString(file: File) {
  return new Promise<string>((resolve, reject) => {
    const fr = new FileReader();
    fr.onload = () => {
      resolve(fr.result as string || '');
    };
    fr.onerror = reject;
    fr.readAsText(file);
  });
}

function exportFavorites() {
  const favoritesString = toolStore.exportFavoriteTools();
  const blob = new Blob([favoritesString], { type: 'application/json' });
  const url = URL.createObjectURL(blob);
  const a = document.createElement('a');
  a.href = url;
  a.download = 'favorites.json';
  a.click();
  URL.revokeObjectURL(url);
}

function importFavoritesFromString() {
  const importInfos = importInfosRaw.value;
  if (importInfos.error) {
    return;
  }
  const string_content = importInfos.string;
  if (!string_content) {
    return;
  }
  toolStore.importFavoriteTools(string_content, replace.value);
}
</script>

<template>
  <div>
    <c-card :title="t('tools.favorites-import-export.export.label')" mb-2>
      <!-- Export section with download as file button -->
      <c-button
        :disabled="toolStore.favoriteTools.length === 0"
        mb-2
        block
        @click="exportFavorites"
      >
        {{ t("tools.favorites-import-export.export.downloadbutton") }}
      </c-button>
      <!-- Export as copyable text (using c-modal-value) -->
      <c-modal-value
        :value="toolStore.exportFavoriteTools()"
        :disabled="toolStore.favoriteTools.length === 0"
        :label="t('tools.favorites-import-export.export.copybutton')"
        mb-2
        block
        size="large"
        type="primary"
      />
    </c-card>
    <c-card :title="t('tools.favorites-import-export.import.label')" mb-2>
      <!-- Import section -->
      <n-radio-group v-model:value="inputType" name="radiogroup" mb-2 flex justify-center>
        <n-space>
          <n-radio
            value="file"
            label="File"
          />
          <n-radio
            value="content"
            label="Content"
          />
        </n-space>
      </n-radio-group>

      <c-file-upload
        v-if="inputType === 'file'"
        :title="t('tools.favorites-import-export.import.uploadPlaceholder')"
        @file-upload="onUpload"
      />

      <c-input-text
        v-if="inputType === 'content'"
        v-model:value="importContent"
        :placeholder="t('tools.favorites-import-export.import.pastePlaceholder')"
        multiline
        mb-2
      />

      <c-divider />

      <textarea-copyable
        label="Parsed import"
        mb-2
        :value="JSON.stringify(importInfosRaw, null, 2)"
      />

      <!-- Optional checkbox to make the import replace existing favorites -->
      <n-form-item label="Replace existing favorites" label-placement="left">
        <n-switch v-model:value="replace" />
      </n-form-item>

      <!-- Import button (disabled if there's no parsed input ) -->
      <c-button
        size="large"
        type="primary"
        block
        @click="importFavoritesFromString"
      >
        <c-icon>
          <icon-upload />
        </c-icon>
        Import favorites
      </c-button>
    </c-card>
  </div>
</template>

<!-- <style lang="less" scoped>
</style> -->
