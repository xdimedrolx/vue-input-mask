<template>
  <div>
    <input-mask v-model="value" mask="+7 (999) 999-99-99"></input-mask>
    <p>{{ value }}</p>
  </div>
</template>

<script>
import Vue from 'vue';
import InputMask from '../../dist';

Vue.component(InputMask.name, InputMask);

export default {
  components: {InputMask},
  name: 'app',

  data() {
    return {
      value: '+79996665544'
    }
  }
}
</script>