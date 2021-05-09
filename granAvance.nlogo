__includes ["MCTS.nls" "MCTS_Aux.nls"]
extensions [sound]

;
; Create  the world with NxN patches and draws the board

breed [negras negra]
breed [blancas blanca]

globals[ turno]

patches-own[ value]
blancas-own[ id]
negras-own [ id]

to-report MCTS:get-content [s]
  report first s
end

; Get the player that generates the state
to-report MCTS:get-playerJustMoved [s]
  report last s
end

; Create a state from the content and player
to-report MCTS:create-state [c p]
  report (list c p)
end

;     0  1  2  3  4  5  6  7
;     .....
;     56 57 58 59 60 61 62 63

; Report that returns the correct lines present in a content (if any)
to-report get:solutions [c]
  ;let LBlan [[56] [57] [58] [59] [60] [61] [62] [63]]
  ;let LNegr [[0] [1] [2] [3] [4] [5] [6] [7]]

  ;let res  filter solution? map [lin -> (map [i -> item i c] lin)] LBlan
  ;show filter [ i -> i < 3 ] [1 3 2]
  let res filter [ i -> (item i c) = 2] (range 56 64)
  ;print (word "res: "res)
  report res
end



;restringir cuando llegue abajo o arriab del todo no dar mas movimientos

; Get the rules applicable to the state
to-report MCTS:get-rules [s]

  let res []
  let c MCTS:get-content s
  let p MCTS:get-playerJustMoved s

  if p = 2[ ;blancas
   foreach c [
      x -> if comprobarBlancas x [
        let aux1 x ;id de piez
        let aux2 position x c ; Posicion de la pieza
        if aux2 > 0 and aux2 < 64[

          let cond1 true
          let cond2 true

          if containsRange aux2 0 8 [report res]

          if  aux2 = 0 or aux2 = 8 or aux2 = 16 or aux2 = 24 or aux2 = 32 or aux2 = 40 or aux2 = 48 or aux2 = 56[
            ;no hay nada delante
            if fichaDelanteBlanca? aux2 c = false [ set res lput (list (aux1) (aux2 - 8)) res]
            ;hay derecha
            if fichaDiagonalDerechaBlanca? aux2 c = false [ set res lput (list (aux1) (aux2 - 7)) res ]

            set cond1 false
          ]

          if aux2 = 7 or aux2 = 15 or aux2 = 23 or aux2 = 31 or aux2 = 39 or aux2 = 47 or aux2 = 55 or aux2 = 63[
            ;no hay nada delante
            if  fichaDelanteBlanca? aux2 c = false [ set res lput (list (aux1) (aux2 - 8)) res]
            ;hay en diagonal izq
            if  fichaDiagonalIzquierdaBlanca? aux2 c = false[ set res lput (list (aux1) (aux2 - 9)) res ]

            set cond2 false
          ]

          if cond1 and cond2[ ; si se cumplen las dos condicicones es que no es de la columna izq ni derecaha

            ;no hay nada delante
            if fichaDelanteBlanca? aux2 c = false [ set res lput (list (aux1) (aux2 - 8)) res]
            ;hay en diagonal izq
            if  fichaDiagonalIzquierdaBlanca? aux2 c = false[ set res lput (list (aux1) (aux2 - 9)) res ]
            ;hay derecha
            if fichaDiagonalDerechaBlanca? aux2 c = false [ set res lput (list (aux1) (aux2 - 7)) res ]
          ]


;          print (word "1.  aux2: " aux2 " aux1: "aux1 " c: " c " res: " res )

        ]
      ]
    ]
  ]
;---------- aqui rules para negras --------------

  if p = 1[ ;negras
   foreach c [
      x -> if comprobarNegras x [
        let aux1 x ;id de piez
        let aux2 position x c ; Posicion de la pieza
        if aux2 > 0 and aux2 < 64[

          let cond1 true
          let cond2 true

          if containsRange aux2 56 64 [report res]

          if  aux2 = 0 or aux2 = 8 or aux2 = 16 or aux2 = 24 or aux2 = 32 or aux2 = 40 or aux2 = 48 or aux2 = 56 [
            ;no hay nada delante
            if fichaDelanteNegra? aux2 c = false [ set res lput (list (aux1) (aux2 + 8)) res]
            ;hay derecha
            if fichaDiagonalDerechaNegra? aux2 c = false [ set res lput (list (aux1) (aux2 + 9)) res ]

            set cond1 false
          ]

          if aux2 = 7 or aux2 = 15 or aux2 = 23 or aux2 = 31 or aux2 = 39 or aux2 = 47 or aux2 = 55 or aux2 = 63[
            ;no hay nada delante
            if  fichaDelanteNegra? aux2 c = false [ set res lput (list (aux1) (aux2 + 8)) res]
            ;hay en diagonal izq
            if  fichaDiagonalIzquierdaNegra? aux2 c = false[ set res lput (list (aux1) (aux2 + 7)) res ]

            set cond2 false
          ]

          if cond1 and cond2[ ; si se cumplen las dos condicicones es que no es de la columna izq ni derecaha

            ;no hay nada delante
            if fichaDelanteNegra? aux2 c = false [ set res lput (list (aux1) (aux2 + 8)) res]
            ;hay en diagonal izq
            if  fichaDiagonalIzquierdaNegra? aux2 c = false[ set res lput (list (aux1) (aux2 + 7)) res ]
            ;hay derecha
            if fichaDiagonalDerechaNegra? aux2 c = false [ set res lput (list (aux1) (aux2 + 9)) res ]
          ]


;        print (word "2.  aux2: " aux2 " aux1: "aux1 " c: " c " res: " res )

        ]
      ]
    ]
  ]

  report res

end



; Apply the rule r to the state s
to-report MCTS:apply [r s]
  let c MCTS:get-content s
  let p MCTS:get-playerJustMoved s


;  set newposX 22 mod 8 set newposY oldposY + 1
;       ask negras with[id = 49] [move-to patch newposX newposY]

  ; Fill the position with the piece and change the player
  let pos last r
  let pie first r
  let lastposition position pie c
;  print (word "0. pos: "pos" pie: "pie" lastposition: "lastposition)

  let listRes replace-item pos c pie
;  print (word "1. "listRes)

  set listRes replace-item lastposition listRes 0
;  print (word "2. "listRes)


  report MCTS:create-state (listRes) (3 - p)
end

to-report MCTS:get-result [s p]
  let pl MCTS:get-playerJustMoved s
  let c MCTS:get-content s
  let val nobody
  ; L will have the lines of the board
  ;
  let L [[0 1 2 3 4 5 6 7] [56 57 58 59 60 61 62 63]]
  ; For every line, we see if it is filled with the same player
  foreach L [
    lin ->
    set val map [x -> (item x c)] lin
  ]
  ifelse member? p val [report 1] [report 0]
  ; if there is no winner lines, and the board is full, then it is a draw
  if empty? MCTS:get-rules s [report 0.5]
  report [false]
end

to setup
  clear-all
  resize-world 0 7 0 7
  set-patch-size 65
  ask patches [
    set pcolor ifelse-value ((pxcor + pycor) mod 2 = 0) [red] [green]

  ]
  set turno "blancas"
  output-print "mueven blancas"
  setup-negras
  setup-blancas
end

to setup-negras
  set-default-shape negras "circle"
  ask patches with[pycor = 6 or pycor = 7] [
  sprout-negras 1 [set color black set size 0.75 ]

  ]
  ask negras[ set id xcor + 8 * ycor + 1
  set label id]

end

to setup-blancas
  set-default-shape blancas "circle"
  ask patches with[pycor = 0 or pycor = 1] [
    sprout-blancas 1 [set color white set size 0.75]
  ]
  ask blancas[ set id xcor + 8 * ycor + 1
  set label id]
end

to play-HvsH
  actualizarTablero
  gana?

  let played? false
  let p nobody
  let oldpos nobody
  let oldposX -1
  let oldposY -1

  let newpos nobody
  let newposX -1
  let newposY -1


;---------------------juegan blancas--------------------------
  if turno = "blancas"[

  if mouse-down?[ ;donde sale true en verdad es para en un futuro elegir el jugador
    if any? blancas-on patch mouse-xcor mouse-ycor [
      set p one-of blancas-on patch mouse-xcor mouse-ycor
      set oldpos patch mouse-xcor mouse-ycor
      set oldposX round mouse-xcor
      set oldposY round mouse-ycor

      ; and move it on a free cell of the board
      while [mouse-down?] [
        ask p [setxy mouse-xcor mouse-ycor]
        set newposX round mouse-xcor
        set newposY round mouse-ycor
      ]
      ; when the mouse is released
        print (word "turno: "turno " oldposX: "oldposX " oldposY:"oldposY)
        print (word "turno: "turno " newposX: "newposX " newposY:"newposY)
      ask p [
        ifelse (not any? other blancas-on patch mouse-xcor mouse-ycor) and (movimientoValido? oldposX oldposY newposX newposY)
        [
          ; move the piece over the cell and set its value
          move-to patch mouse-xcor mouse-ycor
;          set value id

          ask negras with[xcor = newposX and ycor = newposY ][die]
          set played? true
          set turno "negras"
          clear-output
          output-print "mueven negras"
        ]
        [
          ; if you released the mouse in a wrong place, the piece is moved again
          ; to its original location
          move-to oldpos
        ]
      ]
    ]

  ]
 ]
;---------------------juegan negras--------------------------

  if turno = "negras"[
  if mouse-down?[ ;donde sale true en verdad es para en un futuro elegir el jugador
    if any? negras-on patch mouse-xcor mouse-ycor [
      set p one-of negras-on patch mouse-xcor mouse-ycor
      set oldpos patch mouse-xcor mouse-ycor
      set oldposX round mouse-xcor
      set oldposY round mouse-ycor
      ; and move it on a free cell of the board
      while [mouse-down?] [
        ask p [setxy mouse-xcor mouse-ycor]
        set newpos patch mouse-xcor mouse-ycor
        set newposX round mouse-xcor
        set newposY round mouse-ycor
      ]
      ; when the mouse is released
        print (word "turno: "turno " oldposX: "oldposX " oldposY:"oldposY)
        print (word "turno: "turno " newposX: "newposX " newposY:"newposY)
      ask p [
        ifelse (not any? other negras-on patch mouse-xcor mouse-ycor) and (movimientoValido?  oldposX oldposY newposX newposY)
        [
          ; move the piece over the cell and set its value
          move-to patch mouse-xcor mouse-ycor
;          set value id
            ask blancas with[xcor = newposX and ycor = newposY ][die]
            set played? true
            set turno "blancas"
            clear-output
            output-print "mueven blancas"

        ]
        [
          ; if you released the mouse in a wrong place, the piece is moved again
          ; to its original location
          move-to oldpos
          show oldpos

        ]
      ]
    ]
  ]
 ]
end


to play-HvsIA
  actualizarTablero
  gana?

  let played? false
  let p nobody
  let oldpos nobody
  let oldposX -1
  let oldposY -1

  let newpos nobody
  let newposX -1
  let newposY -1


;---------------------juegan blancas--------------------------
  if turno = "blancas"[


  if mouse-down?[ ;donde sale true en verdad es para en un futuro elegir el jugador
    if any? blancas-on patch mouse-xcor mouse-ycor [
      set p one-of blancas-on patch mouse-xcor mouse-ycor
      set oldpos patch mouse-xcor mouse-ycor
      set oldposX round mouse-xcor
      set oldposY round mouse-ycor

      ; and move it on a free cell of the board
      while [mouse-down?] [
        ask p [setxy mouse-xcor mouse-ycor]
        set newposX round mouse-xcor
        set newposY round mouse-ycor
      ]
        actualizarTablero
      ; when the mouse is released
        print (word "turno: "turno " oldposX: "oldposX " oldposY:"oldposY)
        print (word "turno: "turno " newposX: "newposX " newposY:"newposY)
      ask p [
        ifelse (not any? other blancas-on patch mouse-xcor mouse-ycor) and (movimientoValido? oldposX oldposY newposX newposY)
        [
          ; move the piece over the cell and set its value
          move-to patch mouse-xcor mouse-ycor
;          set value id

          ask negras with[xcor = newposX and ycor = newposY ][die]
          set played? true
          set turno "negras"
          clear-output
          output-print "mueven negras"
        ]
        [
          ; if you released the mouse in a wrong place, the piece is moved again
          ; to its original location
          move-to oldpos
        ]
      ]
    ]
    ]
  ]

;---------------------juegan negras--------------------------
 if turno = "negras"[

;  if turno = "negras" [
    ; lets take the move from the MCTS algorithm
    let m MCTS:UCT (list (board-to-state) 1) Max_iterations

    let pie first m
    let pos last m

    show m

    wait 1

    set newposX pos mod 8

    set newposY first [ycor] of negras with [id = pie]
    set newposY newposY - 1

    print(word "newposX: "newposX " newposY: "newposY)

    ask one-of negras with [id = pie][

          move-to patch newposX newposY
          set played? true
          set turno "blancas"
          set value id
          ask blancas with[xcor = newposX and ycor = newposY ][die]
          clear-output
          output-print "mueven negras"
     sound:play-drum "ACOUSTIC SNARE" 64

        ]

  ]
end
@#$#@#$#@
GRAPHICS-WINDOW
192
10
720
539
-1
-1
65.0
1
10
1
1
1
0
0
0
1
0
7
0
7
0
0
1
ticks
30.0

BUTTON
2
10
187
52
NIL
setup
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
2
102
188
144
NIL
play-HvsH
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

OUTPUT
1
54
188
100
15

BUTTON
3
148
188
186
NIL
play-HvsIA
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SLIDER
742
13
914
46
Max_iterations
Max_iterations
1
10000
1.0
1000
1
NIL
HORIZONTAL

MONITOR
743
60
917
105
Action...
(word \"Thinking: \" (count MCTSnodes) \" ...\")
17
1
11

@#$#@#$#@
## JUEGO GRAN AVANCE
Esta implementación en Netlogo del juego Gran Avance ha sido la propuesta por el profesor de Inteligencia Artificial, Fernando Sancho Caparrini al grupo 8, compuesto de 4 personas: 

* PUERTO BORREGUERO, ANTONIO JOSE
* RUIZ JURADO, PABLO
* RUIZ MONGE, JOSE LUIS
* CHURA PASCUAL, ALBARO



## ¿QUÉ ES?

Gran Avance es un abstracto juego de estrategia inventado por Dan Troyka en el año 2000. En el 2001 ganó la Competición de Diseño de Juegos 8x8 y tiene cierta similitud con las damas, pero la estrategia es completamente diferente.

Se juega sobre un tablero de 8x8 casillas con fichas blancas y negras.

El objetivo del juego consiste en alcanzar la fila principal del adversario - la más alejada respecto del jugador. Esto significa que el jugador blanco debe alcanzar la octava fila y que el negro debe alcanzar la primera fila para ganar la partida.

Cada jugador mueve una ficha por turno. Una ficha puede ser movida una casilla hacia delante frontal o diagonalmente siempre y cuando la casilla de destino esté libre. Una ficha puede también ser movida a una casilla ocupada por otra del rival siempre y cuando esté una casilla delante diagonalmente. 

La partida finaliza si uno de los jugadores alcanza la fila principal del adversario.

## COMO SE USA

Para usarlo haz click en el boton HvsH en caso de que quieran jugar dos jugadors humanos o si prefieres jugar contra una inteligencia aritficial haz click en HvsIA. Trás esto haz click en setup.

Ahora solo tienes que hacer click en la ficha que quieras mover en caso de que el juego muestre tu turno y arrastrarla a la casilla donde se desee moverla.

Una vez finalizada la partida se mostrará un cartel donde se indique que jugador ha ganado, trás esto puedes volver a hacer click en setup para reinciar la partida y volver a jugar.

## BIBLIOTECAS USADAS
MCTS, proporcionada por el profesor

@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

airplane
true
0
Polygon -7500403 true true 150 0 135 15 120 60 120 105 15 165 15 195 120 180 135 240 105 270 120 285 150 270 180 285 210 270 165 240 180 180 285 195 285 165 180 105 180 60 165 15

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

box
false
0
Polygon -7500403 true true 150 285 285 225 285 75 150 135
Polygon -7500403 true true 150 135 15 75 150 15 285 75
Polygon -7500403 true true 15 75 15 225 150 285 150 135
Line -16777216 false 150 285 150 135
Line -16777216 false 150 135 15 75
Line -16777216 false 150 135 285 75

bug
true
0
Circle -7500403 true true 96 182 108
Circle -7500403 true true 110 127 80
Circle -7500403 true true 110 75 80
Line -7500403 true 150 100 80 30
Line -7500403 true 150 100 220 30

butterfly
true
0
Polygon -7500403 true true 150 165 209 199 225 225 225 255 195 270 165 255 150 240
Polygon -7500403 true true 150 165 89 198 75 225 75 255 105 270 135 255 150 240
Polygon -7500403 true true 139 148 100 105 55 90 25 90 10 105 10 135 25 180 40 195 85 194 139 163
Polygon -7500403 true true 162 150 200 105 245 90 275 90 290 105 290 135 275 180 260 195 215 195 162 165
Polygon -16777216 true false 150 255 135 225 120 150 135 120 150 105 165 120 180 150 165 225
Circle -16777216 true false 135 90 30
Line -16777216 false 150 105 195 60
Line -16777216 false 150 105 105 60

car
false
0
Polygon -7500403 true true 300 180 279 164 261 144 240 135 226 132 213 106 203 84 185 63 159 50 135 50 75 60 0 150 0 165 0 225 300 225 300 180
Circle -16777216 true false 180 180 90
Circle -16777216 true false 30 180 90
Polygon -16777216 true false 162 80 132 78 134 135 209 135 194 105 189 96 180 89
Circle -7500403 true true 47 195 58
Circle -7500403 true true 195 195 58

circle
false
0
Circle -7500403 true true 0 0 300

circle 2
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240

cow
false
0
Polygon -7500403 true true 200 193 197 249 179 249 177 196 166 187 140 189 93 191 78 179 72 211 49 209 48 181 37 149 25 120 25 89 45 72 103 84 179 75 198 76 252 64 272 81 293 103 285 121 255 121 242 118 224 167
Polygon -7500403 true true 73 210 86 251 62 249 48 208
Polygon -7500403 true true 25 114 16 195 9 204 23 213 25 200 39 123

cylinder
false
0
Circle -7500403 true true 0 0 300

dot
false
0
Circle -7500403 true true 90 90 120

face happy
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 255 90 239 62 213 47 191 67 179 90 203 109 218 150 225 192 218 210 203 227 181 251 194 236 217 212 240

face neutral
false
0
Circle -7500403 true true 8 7 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Rectangle -16777216 true false 60 195 240 225

face sad
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 168 90 184 62 210 47 232 67 244 90 220 109 205 150 198 192 205 210 220 227 242 251 229 236 206 212 183

fish
false
0
Polygon -1 true false 44 131 21 87 15 86 0 120 15 150 0 180 13 214 20 212 45 166
Polygon -1 true false 135 195 119 235 95 218 76 210 46 204 60 165
Polygon -1 true false 75 45 83 77 71 103 86 114 166 78 135 60
Polygon -7500403 true true 30 136 151 77 226 81 280 119 292 146 292 160 287 170 270 195 195 210 151 212 30 166
Circle -16777216 true false 215 106 30

flag
false
0
Rectangle -7500403 true true 60 15 75 300
Polygon -7500403 true true 90 150 270 90 90 30
Line -7500403 true 75 135 90 135
Line -7500403 true 75 45 90 45

flower
false
0
Polygon -10899396 true false 135 120 165 165 180 210 180 240 150 300 165 300 195 240 195 195 165 135
Circle -7500403 true true 85 132 38
Circle -7500403 true true 130 147 38
Circle -7500403 true true 192 85 38
Circle -7500403 true true 85 40 38
Circle -7500403 true true 177 40 38
Circle -7500403 true true 177 132 38
Circle -7500403 true true 70 85 38
Circle -7500403 true true 130 25 38
Circle -7500403 true true 96 51 108
Circle -16777216 true false 113 68 74
Polygon -10899396 true false 189 233 219 188 249 173 279 188 234 218
Polygon -10899396 true false 180 255 150 210 105 210 75 240 135 240

house
false
0
Rectangle -7500403 true true 45 120 255 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7500403 true true 15 120 150 15 285 120
Line -16777216 false 30 120 270 120

leaf
false
0
Polygon -7500403 true true 150 210 135 195 120 210 60 210 30 195 60 180 60 165 15 135 30 120 15 105 40 104 45 90 60 90 90 105 105 120 120 120 105 60 120 60 135 30 150 15 165 30 180 60 195 60 180 120 195 120 210 105 240 90 255 90 263 104 285 105 270 120 285 135 240 165 240 180 270 195 240 210 180 210 165 195
Polygon -7500403 true true 135 195 135 240 120 255 105 255 105 285 135 285 165 240 165 195

line
true
0
Line -7500403 true 150 0 150 300

line half
true
0
Line -7500403 true 150 0 150 150

pentagon
false
0
Polygon -7500403 true true 150 15 15 120 60 285 240 285 285 120

person
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105

plant
false
0
Rectangle -7500403 true true 135 90 165 300
Polygon -7500403 true true 135 255 90 210 45 195 75 255 135 285
Polygon -7500403 true true 165 255 210 210 255 195 225 255 165 285
Polygon -7500403 true true 135 180 90 135 45 120 75 180 135 210
Polygon -7500403 true true 165 180 165 210 225 180 255 120 210 135
Polygon -7500403 true true 135 105 90 60 45 45 75 105 135 135
Polygon -7500403 true true 165 105 165 135 225 105 255 45 210 60
Polygon -7500403 true true 135 90 120 45 150 15 180 45 165 90

sheep
false
15
Circle -1 true true 203 65 88
Circle -1 true true 70 65 162
Circle -1 true true 150 105 120
Polygon -7500403 true false 218 120 240 165 255 165 278 120
Circle -7500403 true false 214 72 67
Rectangle -1 true true 164 223 179 298
Polygon -1 true true 45 285 30 285 30 240 15 195 45 210
Circle -1 true true 3 83 150
Rectangle -1 true true 65 221 80 296
Polygon -1 true true 195 285 210 285 210 240 240 210 195 210
Polygon -7500403 true false 276 85 285 105 302 99 294 83
Polygon -7500403 true false 219 85 210 105 193 99 201 83

square
false
0
Rectangle -7500403 true true 30 30 270 270

square 2
false
0
Rectangle -7500403 true true 30 30 270 270
Rectangle -16777216 true false 60 60 240 240

star
false
0
Polygon -7500403 true true 151 1 185 108 298 108 207 175 242 282 151 216 59 282 94 175 3 108 116 108

target
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240
Circle -7500403 true true 60 60 180
Circle -16777216 true false 90 90 120
Circle -7500403 true true 120 120 60

tree
false
0
Circle -7500403 true true 118 3 94
Rectangle -6459832 true false 120 195 180 300
Circle -7500403 true true 65 21 108
Circle -7500403 true true 116 41 127
Circle -7500403 true true 45 90 120
Circle -7500403 true true 104 74 152

triangle
false
0
Polygon -7500403 true true 150 30 15 255 285 255

triangle 2
false
0
Polygon -7500403 true true 150 30 15 255 285 255
Polygon -16777216 true false 151 99 225 223 75 224

truck
false
0
Rectangle -7500403 true true 4 45 195 187
Polygon -7500403 true true 296 193 296 150 259 134 244 104 208 104 207 194
Rectangle -1 true false 195 60 195 105
Polygon -16777216 true false 238 112 252 141 219 141 218 112
Circle -16777216 true false 234 174 42
Rectangle -7500403 true true 181 185 214 194
Circle -16777216 true false 144 174 42
Circle -16777216 true false 24 174 42
Circle -7500403 false true 24 174 42
Circle -7500403 false true 144 174 42
Circle -7500403 false true 234 174 42

turtle
true
0
Polygon -10899396 true false 215 204 240 233 246 254 228 266 215 252 193 210
Polygon -10899396 true false 195 90 225 75 245 75 260 89 269 108 261 124 240 105 225 105 210 105
Polygon -10899396 true false 105 90 75 75 55 75 40 89 31 108 39 124 60 105 75 105 90 105
Polygon -10899396 true false 132 85 134 64 107 51 108 17 150 2 192 18 192 52 169 65 172 87
Polygon -10899396 true false 85 204 60 233 54 254 72 266 85 252 107 210
Polygon -7500403 true true 119 75 179 75 209 101 224 135 220 225 175 261 128 261 81 224 74 135 88 99

wheel
false
0
Circle -7500403 true true 3 3 294
Circle -16777216 true false 30 30 240
Line -7500403 true 150 285 150 15
Line -7500403 true 15 150 285 150
Circle -7500403 true true 120 120 60
Line -7500403 true 216 40 79 269
Line -7500403 true 40 84 269 221
Line -7500403 true 40 216 269 79
Line -7500403 true 84 40 221 269

wolf
false
0
Polygon -16777216 true false 253 133 245 131 245 133
Polygon -7500403 true true 2 194 13 197 30 191 38 193 38 205 20 226 20 257 27 265 38 266 40 260 31 253 31 230 60 206 68 198 75 209 66 228 65 243 82 261 84 268 100 267 103 261 77 239 79 231 100 207 98 196 119 201 143 202 160 195 166 210 172 213 173 238 167 251 160 248 154 265 169 264 178 247 186 240 198 260 200 271 217 271 219 262 207 258 195 230 192 198 210 184 227 164 242 144 259 145 284 151 277 141 293 140 299 134 297 127 273 119 270 105
Polygon -7500403 true true -1 195 14 180 36 166 40 153 53 140 82 131 134 133 159 126 188 115 227 108 236 102 238 98 268 86 269 92 281 87 269 103 269 113

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270
@#$#@#$#@
NetLogo 6.1.0
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 0.0 1.0
0.0 1 1.0 0.0
0.2 0 0.0 1.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180
@#$#@#$#@
0
@#$#@#$#@
