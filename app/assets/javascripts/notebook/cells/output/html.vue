<script>
import { sanitize } from 'dompurify';
import Prompt from '../prompt.vue';

export default {
  components: {
    Prompt,
  },
  props: {
    count: {
      type: Number,
      required: true,
    },
    rawCode: {
      type: String,
      required: true,
    },
    index: {
      type: Number,
      required: true,
    },
  },
  computed: {
    sanitizedOutput() {
      return sanitize(this.rawCode, {
        ALLOWED_ATTR: ['src'],
      });
    },
    showOutput() {
      return this.index === 0;
    },
  },
};
</script>

<template>
  <div class="output">
    <prompt type="Out" :count="count" :show-output="showOutput" />
    <div v-html="sanitizedOutput"></div>
  </div>
</template>
