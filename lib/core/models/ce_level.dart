enum CeLevel { a1, a2, b1, b2, c1, c2 }

String ceLevelText(CeLevel l) => const ["A1", "A2", "B1", "B2", "C1", "C2"][l.index];

int ceLevelToInt(CeLevel l) => l.index;

CeLevel ceLevelFromInt(int v) => CeLevel.values[(v.clamp(0, 5))];
