/// Zentrale Kennzahlen fuer das Batch-Lernen im Lese-Modul.
class ReadingPool {
  ReadingPool._();

  // Buchstaben-Woerter
  static const wordsMax = 10; // maximale Pool-Groesse pro Runde
  static const wordsNewest = 3; // die neuesten N sind immer im Pool

  // Lautverbindungen
  static const combosMax = 6;
  static const combosNewest = 2;
}
