<script setup lang="ts">
import _ from 'lodash';
import convert, { type Unit } from 'convert';
import * as unitsconverter from 'units-converter';

const props = withDefaults(defineProps<{
  supportedUnits: { [key: string]: string }
  defaultUnit: string
  labelWidth?: string
  unitMinWidth?: string
  converterType: 'convert' | 'frequency' | 'volumeFlowRate' | 'speed' | 'acceleration'
}>(), {
  labelWidth: '150px',
  unitMinWidth: '50px',
  converterType: 'convert',
});
const { supportedUnits, defaultUnit, labelWidth, unitMinWidth, converterType } = toRefs(props);

const SI_PREFIX_NAMES = [
  'quetta',
  'ronna',
  'yotta',
  'zetta',
  'exa',
  'peta',
  'tera',
  'giga',
  'mega',
  'kilo',
  'hecto',
  'deca',
  'deci',
  'centi',
  'milli',
  'micro',
  'nano',
  'pico',
  'femto',
  'atto',
  'zepto',
  'yocto',
  'ronto',
  'quecto',
] as const;

const SI_PREFIX_NAMES_REGEX = new RegExp(`^(${SI_PREFIX_NAMES.join('|')})`);

const units = reactive<
  Record<
    string,
    { title: string; unit: string; ref: number }
  >
      >(Object.entries(supportedUnits.value).map(([key, label]) => ({
        title: label,
        unit: key,
        ref: 1,
      })).reduce((prev, current) => ({
        ...prev,
        [current.unit]: current,
      }), {}));

function update(key: string) {
  if (!units[key]) {
    return;
  }
  const { ref: value } = units[key];

  if (converterType.value === 'convert') {
    const converter = convert(value, key as Unit);

    _.chain(units)
      .omit(key)
      .forEach(({ unit }) => {
        try {
          units[unit].ref = converter.to(unit as Unit);
        }
        catch (e: any) {
          units[unit].ref = 0;
        }
      })
      .value();
  }
  else {
    const converter = unitsconverter[converterType.value](value).from(key);

    _.chain(units)
      .omit(key)
      .forEach(({ unit }) => {
        try {
          units[unit].ref = converter.to(unit).value;
        }
        catch (e: any) {
          units[unit].ref = 0;
        }
      })
      .value();
  }
}

update(defaultUnit.value);
</script>

<template>
  <div>
    <n-input-group v-for="[key, { title, unit }] in Object.entries(units)" :key="key" mb-3 w-full>
      <n-input-group-label :style="{ width: labelWidth }">
        {{ title }}
      </n-input-group-label>

      <n-input-number
        v-model:value="units[key].ref"
        style="flex: 1"
        @update:value="() => update(key)"
      />

      <n-input-group-label :style="{ minWidth: unitMinWidth }">
        {{ unit }}
      </n-input-group-label>
    </n-input-group>
  </div>
</template>
