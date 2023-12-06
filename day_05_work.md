start-to-seed map:
55 55 13 => (55, 68) -> (55, 68), offset 0
79 79 14 => (79, 93) -> (79, 93), offset 0

seed-to-soil map:
50 98 2 => (98, 100) -> (50, 52), offset -48
52 50 48 => (50, 98) -> (52, 100), offset +2

start-to-soil map ranges:
(55, 68) => (53, 66), offset -2
(79, 93) => (77, 91), offset -2

soil-to-fertilizer map:
0 15 37 => (15, 52) -> (0, 37), offset -15
37 52 2 => (52, 54) -> (37, 39), offset -15
39 0 15 => (0, 15) -> (39, 54), offset +39

start-to-fertilizer map ranges:
(55, 56) => (37, 38), offset -15
(57, 68) => (57, 68), offset 0
(79, 93) => (79, 93), offset 0

fertilizer-to-water map:
49 53 8 => (53, 61) -> (49, 57), offset -4
0 11 42 => (11, 53) -> (0, 42), offset -11
42 0 7 => (0, 7) -> (42, 49), offset +42
57 7 4 => (7, 11) -> (57, 61), offset +50

start-to-water map ranges:
(55, 56) => (51, 52), offset -4
(57, 61) => (53, 57), offset -4
(62, 68) => (62, 68), offset 0
(79, 93) => (79, 93), offset 0

water-to-light map:
88 18 7 => (18, 25) -> (88, 95), offset +80
18 25 70 => (25, 95) -> (18, 88), offset -7

start-to-light map ranges:
(55,56) => (48,49), offset -7
(57,61) => (50,54), offset -7
(62,68) => (55,51), offset -7
(79,93) => (72,86), offset -7


algorithm:


