<template>
  <v-app>
    <v-content>
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
                        :color="typeColors[type]"
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
                            :color="typeColors[type]"
                            v-for="([type, value]) in getEffectiveTypes(check)"
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
                            <td class="font-weight-medium">{{value}}</td>
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
    </v-content>
  </v-app>
</template>

<script>
import pokemon from "@/data/pokemon.json";
import types from "@/data/types.json";
import typeColors from "@/data/typeColors.json";

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
      typeColors,
      effectivenessGroups,
      selectedPokemon: null
    };
  },
  computed: {
    toolbarColor() {
      if (!this.selectedPokemon) return "primary";
      return this.typeColors[this.selectedPokemon.type[0]];
    },
    typeEffectiveness() {
      if (!this.selectedPokemon) return null;

      return this.selectedPokemon.type.reduce((acc, defendingType) => {
        Object.entries(types).forEach(([attackingType, modifiers]) => {
          Object.entries(modifiers).forEach(
            ([modifierString, modifiedTypes]) => {
              if (modifiedTypes.includes(defendingType)) {
                if (!acc[attackingType]) {
                  acc[attackingType] = parseFloat(modifierString);
                } else {
                  acc[attackingType] *= parseFloat(modifierString);
                }
              }
            }
          );
        });
        return acc;
      }, {});
    }
  },
  methods: {
    getEffectiveTypes(check) {
      return Object.entries(this.typeEffectiveness)
        .filter(([, value]) => check(value))
        .sort(([, aValue], [, bValue]) => bValue - aValue);
    }
  },
  filters: {
    padNo(value) {
      return String(value).padStart(3, "0");
    },
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
</style>