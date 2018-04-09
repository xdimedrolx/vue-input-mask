<template>
  <div>
    <input-mask v-model="phone" mask="+7 (999) 999-99-99"></input-mask>
    <p>{{ phone }}</p>

    <input-mask v-model="phoneTimeout" mask="+7 (999) 999-99-99"></input-mask>
    <p>{{ phoneTimeout }}</p>

    <input-mask v-model="passport" mask="99999 999999"></input-mask>
    <p>{{ passport }}</p>

    <input-mask disabled v-model="passportDisabled" mask="99999 999999"></input-mask>
    <p>{{ passportDisabled }}</p>
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
      phone: '+79996665544',
      phoneTimeout: null,
      passport: '99999 123456',
      passportDisabled: '99999 123456'
    }
  },

  mounted () {
    setTimeout(() => {
      this.phoneTimeout = '+79996665544'
    }, 700)
  },
}
</script>