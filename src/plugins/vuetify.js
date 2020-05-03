import Vue from 'vue';
import Vuetify from 'vuetify/lib';
import colors from 'vuetify/lib/util/colors';

Vue.use(Vuetify);

const mq = window.matchMedia('(prefers-color-scheme: dark)');

const vuetify = new Vuetify({
    theme: {
        dark: mq.matches,
        themes: {
            light: {
                primary: colors.grey
            },
            dark: {
                primary: colors.grey.darken2
            }
        }
    }
});

mq.addEventListener('change', e => {
    vuetify.framework.theme.dark = e.matches;
});

export default vuetify;