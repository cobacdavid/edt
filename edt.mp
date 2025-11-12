%% edt.mp

%% Ensemble de macros metapost pour établir un emploi du temps
%%
%% auteur : David Cobac <dcobac@free.fr>
%% date : Janvier 2007
%% révision : Novembre 2025
%% version 0.7

% License
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%	
%     This program is free software; you can redistribute it and/or modify
%     it under the terms of the GNU General Public License as published by
%     the Free Software Foundation; either version 2 of the License, or
%     (at your option) any later version.

%     This program is distributed in the hope that it will be useful,
%     but WITHOUT ANY WARRANTY; without even the implied warranty of
%     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%     GNU General Public License for more details.

%     You should have received a copy of the GNU General Public License
%     along with this program; if not, write to the Free Software
%     Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%	
%% À voir :
%%   - génération de figures indiv. par classe
%%   - plus de formes de rectangles

input boxes;
input string;

%%
%%
numeric numeroImagen,idClasse[];
numeroImage=0;
picture fond,imageCreneau[],imageCreneauEvi[];
string  nomJour[];
numeric numeroCreneau[];
%%
%%
heuresAM=4;
dureeMidi=1.5;
heuresPM=3;
heuresPMMercredi=0;
%%
arrondiB=1;
largeurB=3cm;
hauteurB=1.5cm;
%%
color noir,blanc,rouge,vert,bleu,gris[];
noir=(0,0,0);
blanc=(1,1,1);
rouge=(1,0,0);
vert=(0,1,0);
bleu=(0,0,1);
for i:=10 step 10 until 90 :
  gris[i]=(i/100)*white;
endfor;
%%
epaisTrait=1bp;
offArrondi=1mm;
offBord=.5mm;
%%
color couleurBJ,couleurPJ;
couleurBJ=blanc;
couleurPJ=noir;
encadreBJ=0;
%%
picture imageHoraires;
imageHoraires:=image();
string optionsFond,taillePoliceHoraire;
optionsFond="";
taillePoliceHoraire="\footnotesize";
%%
color policeEvi,fondEvi,bordEvi;
policeEvi:=blanc;
fondEvi:=.5rouge;
bordEvi:=.2rouge;

%% définitions des jours entêtes de
%% l'emploi du temps
vardef jours (text t) :=
  fond:=image(
  string jour[];
  i:=1;
  %% on met nos jours dans un tableau
  %% ça peut toujours être utile !
  forsuffixes $=t :
	jour[i]:=str $;
	i:=i+1;
  endfor;

  boxjoin(a.se=b.sw;a.ne=b.nw);
  forsuffixes $=t :
    	boxit.$(textext("\makebox[" & decimal(largeurB) & "pt]{\bfseries " & str $ & "}"));
	if (encadreBJ=1) :
	  fill bpath.$ withcolor couleurBJ;
	fi;
	draw pic $ withcolor couleurPJ;
  endfor;

  forsuffixes $=t :
	if (str $ = "Mercredi") :
	  defHeuresJour($)(heuresAM,heuresPMMercredi);
	elseif (str $ = "Samedi") :
	  defHeuresJour($)(heuresAM,0);
	else :
	  defHeuresJour($)(heuresAM,heuresPM);
	fi;
  endfor;
  );
enddef;

%% construction du quadrillage pour une journée
%% arg1 : le jour concerné tel que défini avec la macro defJours
%% arg2 : Nb heures dans la matinée
%% arg3 : Nb heures dans la soirée
vardef defHeuresJour (text t)(expr am,pm) :=
  boxjoin(a.sw=b.nw;a.se=b.ne);
  
%% le matin
  for i:=1 upto am :
	boxit.t[i]();
	t[i].sw=t[i].nw shifted (0,-hauteurB);
  endfor;

  j:=am;
  if (pm<>0) :  
%% le midi
	i:=am+1;
	boxit.t[i]();
	t[i].sw=t[i].nw shifted (0,-dureeMidi*hauteurB);
	
%% le soir
	for i:=am+2 upto am+pm+1 :
	  boxit.t[i]();
	  t[i].sw=t[i].nw shifted (0,-hauteurB);
	endfor;

	j:=am+pm+1;
  fi;
  
	t.sw=t1.nw;t.se=t1.ne;
  
	for i:=1 upto j :
	  scantokens( "drawoptions(" & optionsFond & ");" );
	  draw bpath(t[i]);
	  drawoptions();
	endfor;
enddef;

%% procédure utilisant l'extension 'string'
%% grâce à l'aide de JM Sarlat sur
%% la liste Syracuse.
vardef montreHoraires (text t) :=
  save i,j,_t_;
  string _t_,$;
  _t_:=t;
  i=1;j:=1;

  imageHoraires:=image(
	forever :
	  $:=loptok _t_;
	  exitif $ = "";
	  if ((j mod 2) = 0) :
		if ($ <> "rien") :
		  label.ulft(textext(taillePoliceHoraire & " " & $),Lundi[i].sw);
		fi;
		i:=i+1;
	  elseif ($ <> "rien") :
	    label.llft(textext(taillePoliceHoraire & " " & $),Lundi[i].nw);
	    label.llft(textext(taillePoliceHoraire & " " & $),Lundi[i].nw);
	  fi;
	  j:=j+1;
	endfor;
	);
enddef;


vardef defCours (text type)(text t)(expr c,duree)(expr intituleClasse)(text intituleSalle) :=
  save xhg,yhg,xbd,ybd;
  save texte;
  save s,classe;
  save coulfond,coulbord,coulpolice;
  color coulfond,coulbord,coulpolice;
  string s,classe;
  picture texte;
  
  numeroImage:=numeroImage+1;
  scantokens("classe=c" &  decimal(intituleClasse) & ";");
  idClasse[numeroImage]:=intituleClasse;
  nomJour[numeroImage]:=str t;
  numeroCreneau[numeroImage]:=c;
  
%% position du label
  xhg = xpart (t.nw);
  xbd = xpart (t.ne);
  yhg = ypart (t[floor(c)].nw) - (c-floor(c))*hauteurB;
  ybd = yhg - (duree*hauteurB); 

  coulpolice:=cp[intituleClasse];
  coulfond:=cf[intituleClasse];
  coulbord:=cb[intituleClasse];

%%%%% type normal %%%%
  if (str type="pleine") :
%% contenu du label
	s="\begin{tabular}{c}" & classe & "\\\mbox{}\hfill\small\textit{"
	& intituleSalle & "}\end{tabular}";
    	texte=textext(s);
%% tracé de l'image
	imageCreneau[numeroImage]:=image(
	  if (arrondiB=1) :
		rectanglearrondi(xhg,yhg,xbd,ybd,coulfond,coulbord);
	  else :
		rectangle(xhg,yhg,xbd,ybd,coulfond,coulbord);
	  fi;
	  label(texte,((xhg+xbd)/2,(yhg+ybd)/2)) withcolor coulpolice;
	  );

	imageCreneauEvi[numeroImage]:=image(
	  if (arrondiB=1) :
		rectanglearrondi(xhg,yhg,xbd,ybd,fondEvi,bordEvi);
	  else :
		rectangle(xhg,yhg,xbd,ybd,fondEvi,bordEvi);
	  fi;
	  label(texte,((xhg+xbd)/2,(yhg+ybd)/2)) withcolor policeEvi;
	  );

%%%%% type QzH %%%%
  elseif ((str type)="QzH") :
%% contenu du label
	s="\begin{tabular}{l}" & classe & "\\\small\textit{"
	& intituleSalle & "}\end{tabular}";
    	texte=textext(s);
%% tracé de l'image
	imageCreneau[numeroImage]:=image(
	  if (arrondiB=1) :
		trianglearrondiH(xhg,yhg,xbd,ybd,coulfond,coulbord);
	  else :
		triangleH(xhg,yhg,xbd,ybd,coulfond,coulbord);
	  fi;
	  label.lrt(texte,(xhg,yhg)) withcolor coulpolice;
	  );
	
	imageCreneauEvi[numeroImage]:=image(
	  if (arrondiB=1) :
		trianglearrondiH(xhg,yhg,xbd,ybd,fondEvi,bordEvi);
	  else :
		triangleH(xhg,yhg,xbd,ybd,fondEvi,bordEvi);
	  fi;
	  label.lrt(texte,(xhg,yhg)) withcolor policeEvi;
	  );
	
%%%%% type QzB %%%%
  elseif ((str type)="QzB") :
%% contenu du label
	s="\begin{tabular}{r}" & classe & "\\\small\textit{"
	& intituleSalle & "}\end{tabular}";
        texte=textext(s);
%% mise en forme
	imageCreneau[numeroImage]:=image(
	  if (arrondiB=1) :
		trianglearrondiB(xhg,yhg,xbd,ybd,coulfond,coulbord);
	  else :
		triangleB(xhg,yhg,xbd,ybd,coulfond,coulbord);
	  fi;
	  label.ulft(texte,(xbd,ybd)) withcolor coulpolice;	
	  );

	imageCreneauEvi[numeroImage]:=image(
	  if (arrondiB=1) :
		trianglearrondiB(xhg,yhg,xbd,ybd,fondEvi,bordEvi);
	  else :
		triangleB(xhg,yhg,xbd,ybd,fondEvi,bordEvi);
	  fi;
	  label.lrt(texte,(xhg,yhg)) withcolor policeEvi;
	  );

  fi;
enddef;


%% arg1 : jour concerné tel que défini..
%% arg2 : contenu de la boîte
%% arg3 : créneau de départ : 1 ou 1.5 (par exemple) 
%% arg4 : durée du créneau
vardef cours (text t)(expr c,duree)(expr intituleClasse)(text intituleSalle) :=
  defCours(pleine)(t)(c,duree)(intituleClasse,intituleSalle);
enddef;
vardef coursQzH (text t)(expr c,duree)(expr intituleClasse)(text intituleSalle) :=
  defCours(QzH)(t)(c,duree)(intituleClasse,intituleSalle);
enddef;
vardef coursQzB (text t)(expr c,duree)(expr intituleClasse)(text intituleSalle) :=
  defCours(QzB)(t)(c,duree)(intituleClasse,intituleSalle);
enddef;


%% définition des classes par numéro
%% on crée 4 tableaux :
%% -classe
%% -couleur de police
%% -couleur du fond
%% -couleur du bord
string c[];
color  cf[],cb[],cp[];
vardef classe (expr id)(text t)(expr _cp_,_cf_,_cb_) :=
  c[id]:=t;
  cf[id]:=_cf_;
  cb[id]:=_cb_;
  cp[id]:=_cp_;
enddef;


vardef rectangle (expr xg,yg,xd,yd,fond,bord) :=
  save p;
  path p;

  xhg:=xg+offBord;
  yhg:=yg-offBord;
  xbd:=xd-offBord;
  ybd:=yd+offBord;

  p:=(xhg,yhg)--(xhg,ybd)--(xbd,ybd)--(xbd,yhg)--cycle;
  fill p withcolor fond;
  draw p withcolor bord withpen pencircle scaled epaisTrait;
enddef;

vardef rectanglearrondi (expr xg,yg,xd,yd,fond,bord) :=
  save p,xhg,yhg,xbd,ybd;
  path p;

  xhg:=xg+offBord;
  yhg:=yg-offBord;
  xbd:=xd-offBord;
  ybd:=yd+offBord;

  p:=(xhg,yhg-offArrondi)--(xhg,ybd+offArrondi){dir -90}..
  (xhg+offArrondi,ybd)--(xbd-offArrondi,ybd){dir 0}..
  (xbd,ybd+offArrondi)--(xbd,yhg-offArrondi){dir 90}..
  (xbd-offArrondi,yhg)--(xhg+offArrondi,yhg){dir 180}..
  cycle;
  fill p withcolor fond;
  draw p withcolor bord withpen pencircle scaled epaisTrait;
enddef;

vardef triangleH (expr xg,yg,xd,yd,fond,bord) :=
  save p,xhg,yhg,xbd,ybd;
  path p;

  xhg:=xg+offBord;
  yhg:=yg-offBord;
  xbd:=xd-offBord-epaisTrait;
  ybd:=yd+offBord+epaisTrait;

  p:=(xhg,yhg)--(xhg,ybd)--(xbd,yhg)--cycle;
  fill p withcolor fond;
  draw p withcolor bord withpen pencircle scaled epaisTrait;
enddef;

vardef trianglearrondiH (expr xg,yg,xd,yd,fond,bord) :=
  save p,xhg,yhg,xbd,ybd;
  path p;

  xhg:=xg+offBord;
  yhg:=yg-offBord;
  xbd:=xd-offBord-epaisTrait;
  ybd:=yd+offBord+epaisTrait;

  p:=(xbd,yhg)--(xhg+offArrondi,yhg){dir 180}..(xhg,yhg-offArrondi){dir -90}--(xhg,ybd)--cycle;
  fill p withcolor fond;
  draw p withcolor bord withpen pencircle scaled epaisTrait;
enddef;

vardef triangleB (expr xg,yg,xd,yd,fond,bord) :=
  save p,xhg,yhg,xbd,ybd;
  path p;

  xhg:=xg+offBord+epaisTrait;
  yhg:=yg-offBord-epaisTrait;
  xbd:=xd-offBord;
  ybd:=yd+offBord;

  p:=(xhg,ybd)--(xbd,ybd)--(xbd,yhg)--cycle;
  fill p withcolor fond;
  draw p withcolor bord withpen pencircle scaled epaisTrait;
enddef;

vardef trianglearrondiB (expr xg,yg,xd,yd,fond,bord) :=
  save p,xhg,yhg,xbd,ybd;
  path p;

  xhg:=xg+offBord+epaisTrait;
  yhg:=yg-offBord-epaisTrait;
  xbd:=xd-offBord;
  ybd:=yd+offBord;

  p:=(xhg,ybd)--(xbd-offArrondi,ybd){dir 0}..(xbd,ybd+offArrondi){dir 90}--(xbd,yhg)--cycle;
  fill p withcolor fond;
  draw p withcolor bord withpen pencircle scaled epaisTrait;
enddef;


def traceFond :=
  draw fond;
  draw imageHoraires;
enddef;

%% id = identifiant de la classe sous la forme "1" ou "1 5 6 7 8"
vardef traceClasse (text id) :=
  save i,_id_,$,s;
  string _id_,$,s;
  _id_=id;
  
  forever :
	$:= loptok _id_;
	exitif $ = "";
	for i:=1 upto numeroImage :
	  scantokens("s:= str " & decimal(idClasse[i]) & ";");
	  if (s = $) :
		draw imageCreneau[i];
	  fi;
	endfor;
  endfor;
enddef;

%% identifiant d'un créneau !!
%% pas tout à fait en fait... :
%% id = le numéro d'appel de la commande cours
vardef traceHeure (expr id) :=
  draw imageCreneau[id];  
enddef;

vardef traceHeureEvi (expr id) :=
  draw imageCreneauEvi[id];  
enddef;


%% 
def traceJour (text nom) :=
  save s;
  string s;
  for i:=1 upto numeroImage :
	s:=str nom;
	if (nomJour[i] = s) :
	  draw imageCreneau[i];
	fi;
  endfor;
enddef;


%% on trace tout : emploi du temps complet
def traceTout :=
  begingroup;
	save i;
	for i:=1 upto numeroImage :
	  traceHeure(i);
	endfor;
  endgroup;
enddef;
