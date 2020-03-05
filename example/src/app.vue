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

    <input-mask v-model="time"
      :mask="timeMask"
      :format-chars="timeMaskOptions.formatChars"
      :always-show-mask="timeMaskOptions.alwaysShowMask"
    ></input-mask>
    <p>{{ time }}</p>

    <input-mask v-model="time1"
        :mask="timeMask"
        :format-chars="timeMaskOptions.formatChars"
        :always-show-mask="timeMaskOptions.alwaysShowMask"
    ></input-mask>
    <p>{{ time1 }}</p>

    <input-mask v-model="time2"
        :mask="timeMask"
        :format-chars="timeMaskOptions.formatChars"
        :always-show-mask="timeMaskOptions.alwaysShowMask"
    ></input-mask>
    <p>{{ time2 }}</p>

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
import InputMask from '../../src';

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
      },
      time: null,
      time1: '23:45',
      time2: '01:15',
    }
  },

  computed: {
    timeMask () {
      if (!this.time || this.time === '' || this.time[0] === '2') {
        console.log('23:59')
        return '23:59'
      }
      console.log('29:59')
      return '29:59'
    },
    timeMaskOptions () {
      return { formatChars: { '2': '[0-2]', '3': '[0-3]', '5': '[0-5]', '9': '[0-9]' }, alwaysShowMask: false }
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