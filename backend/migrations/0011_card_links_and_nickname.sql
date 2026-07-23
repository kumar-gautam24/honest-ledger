-- 0011_card_links_and_nickname
--
-- Explicit card links replace lender-guessing for folding obligations into a
-- card's statement. A borrowing or recurring item can now name the exact card
-- it is billed on (two cards from the same bank are otherwise indistinguishable
-- to the fold-in). `nickname` lets the user label same-bank cards ("ICICI
-- Amazon Pay" vs "ICICI Coral"). All three are nullable and additive: the
-- shipped v1 client omits them and keeps working; a null card_id falls back to
-- lender matching on the client.
ALTER TABLE borrowings ADD COLUMN card_id TEXT;
ALTER TABLE recurring_items ADD COLUMN card_id TEXT;
ALTER TABLE cards ADD COLUMN nickname TEXT;
