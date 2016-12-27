//PROG0805.C
nums=2;
  guess=5;
  while (guess <= limit) {
    for (factor=2; factor < guess; factor ++)
      if (guess % factor == 0)
        break;
      if (factor > guess) {
        nums++;
        maxprime=guess;
      }
    guess ++;
  }