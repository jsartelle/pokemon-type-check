{
    "ノーマル": "Normal",
    "かくとう": "Fighting",
    "ひこう": "Flying",
    "どく": "Poison",
    "じめん": "Ground",
    "いわ": "Rock",
    "むし": "Bug",
    "ゴースト": "Ghost",
    "はがね": "Steel",
    "ほのお": "Fire",
    "みず": "Water",
    "くさ": "Grass",
    "でんき": "Electric",
    "エスパー": "Psychic",
    "こおり": "Ice",
    "ドラゴン": "Dragon",
    "あく": "Dark",
    "フェアリー": "Fairy"
}
as $types |

map({
    name: .English,
    no: .No,
    form: (if .Form == "-" then null else .Form end),
    type: [
        $types[.Type1] // empty,
        $types[.Type2] // empty
    ],
    stats: {
        hp: .H,
        attack: .A,
        defense: .B,
        spAttack: .C,
        spDefense: .D,
        speed: .S
    }
})