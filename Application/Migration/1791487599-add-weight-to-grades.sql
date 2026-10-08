-- Peso de cada nota, usado no cálculo da média ponderada. Notas existentes ficam com peso 1.
ALTER TABLE grades ADD COLUMN weight DOUBLE PRECISION DEFAULT 1 NOT NULL;
