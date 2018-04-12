<template>
  <div>
    <input-mask v-model="phone" mask="+7 (999) 999-99-99"></input-mask>
    <p>{{ phone }}</p>

    <input-mask v-model="phoneTimeout" mask="+7 (999) 999-99-99"></input-mask>
    <p>{{ phoneTimeout }}</p>

    <input-mask v-model="nullPassportTimeout" mask="99999 999999"></input-mask>
    <p>{{ nullPassportTimeout }}</p>

    <input-mask v-model="passport" mask="99999 999999"></input-mask>
    <p>{{ passport }}</p>

    <input-mask disabled v-model="passportDisabled" mask="99999 999999"></input-mask>
    <p>{{ passportDisabled }}</p>

    <input-mask v-model="defaultValue" mask="+7 (999) 999-99-99" default-value="+79996665544"></input-mask>
    <p>{{ defaultValue }}</p>

    <form>
      <input-mask v-model="auth.login" mask="+7 (999) 999-99-99" name="username"></input-mask>
      <input type="password" v-model="auth.password" name="current-password"></input>
      <button>Войти</button>
    </form>

    {{ $data }}
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
      defaultValue: null,
      phone: '+79996665544',
      phoneTimeout: null,
      passport: '99999 123456',
      passportDisabled: '99999 123456',
      nullPassportTimeout: null,
      auth: {
        login: '',
        password: ''
      }
    }
  },

  mounted () {
    setTimeout(() => {
      this.phoneTimeout = '+79996665544'
      this.nullPassportTimeout = null
    }, 700)
  },
}
</script>