#include <iostream>
using namespace std;

/* Console Windows am�lior�e
   Il faut renomer le main() en execute()
   et compiler le programme pour Windows...
   
   Pour am�liorer l'ergonomie, on peut cr�er
   un template � partir de ce projet :
   Menu:Fichier:Nouveau:Template... */
   
void execute(){
  std::string str; 
    
  cout << "Sortie sur console" << endl;
  cerr << "Affiche un message d'erreur" << endl;
  clog << "Affiche un message\r\npar exemple l'�volution de la m�moire" << endl;
  cin >> str;
  cout << "Entr�e au clavier : " << str << endl;     
  cout << "Fin Test" << endl;
}     
