<template>
  <v-app>
    <v-main>
      <v-container class="fill-height">
        <v-row
          align="center"
          justify="center"
        >
          <v-col cols="12">
            <v-card raised>
              <v-toolbar
                class="toolbar"
                :color="toolbarColor"
              >
                <v-autocomplete
                  v-model="selectedPokemon"
                  :items="pokemon"
                  :item-text="item => item.name + (item.form ? ` (${item.form})` : '')"
                  menu-props="closeOnContentClick"
                  return-object
                  autofocus
                  clearable
                  hide-no-data
                  hide-details
                  flat
                  solo
                  label="Search for a Pokémon"
                ></v-autocomplete>
              </v-toolbar>

              <v-card-text v-if="selectedPokemon">
                <v-row class="px-5">
                  <v-col cols="6">
                    <v-card-title class="pokemon-name">{{selectedPokemon.name}} <span class="font-weight-regular">#{{selectedPokemon.no | padNo}}</span></v-card-title>
                    <v-card-subtitle>{{selectedPokemon.form}}</v-card-subtitle>
                  </v-col>

                  <v-col
                    cols="6"
                    class="d-flex justify-end align-center"
                  >
                    <v-chip-group column>
                      <v-chip
                        class="type-chip white--text elevation-3"
                        :color="types[type].color"
                        v-for="type in selectedPokemon.type"
                        :key="type"
                      >{{type}}</v-chip>
                    </v-chip-group>
                  </v-col>

                  <v-col cols="6">
                    <v-simple-table>
                      <template #default>
                        <thead>
                          <tr>
                            <th
                              colspan="2"
                              class="subtitle-1"
                            >Type Effectiveness</th>
                          </tr>
                        </thead>
                      </template>
                    </v-simple-table>

                    <v-list>
                      <template v-for="({label, check}, index) in effectivenessGroups">
                        <v-divider
                          v-if="index > 0"
                          :key="`divider-${index}`"
                        ></v-divider>
                        <v-subheader
                          class="subtitle-2"
                          :key="`subheader-${index}`"
                        >{{label}}</v-subheader>
                        <v-chip-group
                          column
                          class="pb-5"
                          :key="`chip-group-${index}`"
                        >
                          <v-chip
                            class="type-chip white--text mx-2 elevation-3"
                            :color="types[type].color"
                            v-for="([type, value]) in typesForEffectivenessGroup(check)"
                            :key="type"
                          >
                            <v-avatar
                              left
                              class="effectiveness"
                            >{{value | fractionize}}×</v-avatar>
                            {{type}}
                          </v-chip>
                        </v-chip-group>
                      </template>
                    </v-list>
                  </v-col>

                  <v-col cols="6">
                    <v-simple-table>
                      <template #default>
                        <thead>
                          <tr>
                            <th
                              colspan="2"
                              class="subtitle-1"
                            >Base Stats</th>
                          </tr>
                        </thead>
                        <tbody>
                          <tr
                            v-for="(value, name) in selectedPokemon.stats"
                            :key="name"
                          >
                            <td>{{name | statName}}</td>
                            <td
                              class="font-weight-medium"
                              :class="statClass(name)"
                            >{{value}}</td>
                          </tr>
                        </tbody>
                      </template>
                    </v-simple-table>
                  </v-col>
                </v-row>
              </v-card-text>

              <v-card-text v-else>
                <v-row class="px-5">
                  <v-col>
                    <v-simple-table
                      class="effectiveness-table"
                      dense
                    >
                      <template #default>
                        <thead>
                          <tr>
                            <td class="legend-cell sticky-cell pa-0">
                              <span>ATK</span>
                              <span>DEF</span>
                            </td>
                            <th
                              v-for="type in Object.keys(types)"
                              :key="type"
                              scope="col"
                              class="text-center white--text"
                              :style="{ backgroundColor: types[type].color }"
                            >{{type | abbreviateType}}</th>
                          </tr>
                        </thead>
                        <tbody>
                          <tr
                            v-for="attackingType in Object.keys(types)"
                            :key="attackingType"
                          >
                            <th
                              scope="row"
                              class="sticky-cell text-center white--text"
                              :style="{ backgroundColor: types[attackingType].color }"
                            >{{attackingType | abbreviateType}}</th>
                            <td
                              v-for="defendingType in Object.keys(types)"
                              :key="defendingType"
                              class="text-center"
                              :class="effectivenessCellClass(types[attackingType].effectiveness[defendingType])"
                            >{{types[attackingType].effectiveness[defendingType] | fractionize | hide1x}}</td>
                          </tr>
                        </tbody>
                      </template>
                    </v-simple-table>
                  </v-col>
                </v-row>
              </v-card-text>
            </v-card>
          </v-col>
        </v-row>
      </v-container>
    </v-main>
  </v-app>
</template>

<script>
import pokemon from "@/data/pokemon.json";
import types from "@/data/types.json";

const effectivenessGroups = [
  {
    label: "Weak to:",
    check: x => x > 1
  },
  {
    label: "Damaged normally by:",
    check: x => x === 1
  },
  {
    label: "Resistant to:",
    check: x => x > 0 && x < 1
  },
  {
    label: "Immune to:",
    check: x => x === 0
  }
];

export default {
  name: "App",
  components: {},
  data() {
    return {
      pokemon,
      types,
      effectivenessGroups,
      selectedPokemon: null
    };
  },
  computed: {
    currentTypeEffectiveness() {
      if (!this.selectedPokemon) return null;

      const effectiveness = {};

      Object.keys(this.types).forEach(attackingType => {
        effectiveness[attackingType] = 1;

        this.selectedPokemon.type.forEach(defendingType => {
          effectiveness[attackingType] *= this.types[
            attackingType
          ].effectiveness[defendingType];
        });
      });

      return effectiveness;
    },
    toolbarColor() {
      if (!this.selectedPokemon) return "primary";
      return this.types[this.selectedPokemon.type[0]].color;
    }
  },
  methods: {
    effectivenessCellClass(effectiveness) {
      switch (effectiveness) {
        case 0:
          return ["bordered-cell"];
        case 0.5:
          return ["red", "darken-2", "white--text"];
        case 2:
          return ["green", "darken-2", "white--text"];
      }
    },
    statClass(statName) {
      const comparisonStat = (() => {
        switch (statName) {
          case "attack":
            return "spAttack";
          case "spAttack":
            return "attack";
          case "defense":
            return "spDefense";
          case "spDefense":
            return "defense";
        }
      })();
      if (!comparisonStat) return [];

      let colorClass = (() => {
        switch (
          Math.sign(
            this.selectedPokemon.stats[statName] -
              this.selectedPokemon.stats[comparisonStat]
          )
        ) {
          case 1:
            return "blue--text";
          case -1:
            return "red--text";
          case 0:
          case -0:
            return;
        }
      })();
      if (!colorClass) return [];

      return [
        colorClass,
        this.$vuetify.theme.dark ? undefined : "text--darken-2"
      ];
    },
    typesForEffectivenessGroup(check) {
      return Object.entries(this.currentTypeEffectiveness)
        .filter(([, value]) => check(value))
        .sort(([, aValue], [, bValue]) => bValue - aValue);
    }
  },
  filters: {
    fractionize(value) {
      switch (value) {
        case 0.5:
          return "½";
        case 0.25:
          return "¼";
        default:
          return value;
      }
    },
    hide1x(value) {
      return value == 1 ? "" : value;
    },
    padNo(value) {
      return String(value).padStart(3, "0");
    },
    abbreviateType(value) {
      return value.slice(0, 3).toUpperCase();
    },
    statName(stat) {
      switch (stat) {
        case "hp":
          return "HP";
        case "attack":
          return "Attack";
        case "defense":
          return "Defense";
        case "spAttack":
          return "Sp. Atk";
        case "spDefense":
          return "Sp. Def";
        case "speed":
          return "Speed";
      }
    }
  }
};
</script>

<style scoped>
.toolbar {
  transition: background 500ms ease;
}

.pokemon-name {
  white-space: pre;
}

.type-chip {
  text-shadow: 0 0 5px black;
}

.type-chip .effectiveness {
  background-color: rgba(0, 0, 0, 0.4);
}

.effectiveness-table th {
  text-shadow: 0 0 5px black;
}

.effectiveness-table .sticky-cell {
  position: sticky;
  left: 0;
}

.effectiveness-table .legend-cell {
  background-color: white;
  background-image: linear-gradient(
    to top right,
    transparent,
    transparent calc(50% - 1px),
    currentColor 50%,
    transparent calc(50% + 1px),
    transparent
  );
}

.theme--dark .effectiveness-table .legend-cell {
  background-color: #1e1e1e;
}

.effectiveness-table .legend-cell span {
  position: absolute;
  font-size: 0.75em;
  line-height: 1;
}

.effectiveness-table .legend-cell span:nth-child(1) {
  bottom: 3px;
  left: 3px;
}

.effectiveness-table .legend-cell span:nth-child(2) {
  top: 3px;
  right: 3px;
}

.effectiveness-table .bordered-cell {
  border: 2px dashed currentColor !important;
}
</style>

<style>
.effectiveness-table table {
  border-collapse: collapse;
}
</style>