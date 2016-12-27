//PROG0806.C
nums=2;
  guess=5;
  while (guess <= limit) {
    for (factor=3; factor < guess; factor += 2)
      if (guess % factor == 0)
        break;
      if (factor > guess) {
        nums++;
        maxprime=guess;
      }
    guess += 2;
  }