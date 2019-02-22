### auxilary functions ###

### import SLV function ###
ru.import.slv<-function(modelName, outs=NULL, delTemp=T) ## create global variables params, initials, .dll with ODEs RHS and outputs
{
### part to read SLV and write files "RHS.temp.txt", "IV.temp.txt", "variables.temp.txt"
slv<-readLines(paste(modelName,".slv",sep=""))

counter<-vector(mode="numeric", length=length(slv))
ct<-0
vars_start<-NULL
vars_end<-NULL
for (i in 1:length(slv))
	{
	t1<-sum(attr(gregexpr("#", slv[i])[[1]],"match.length"))
	if (t1<0) t1<-0
	ct<-ct+t1
	counter[i]<-ct
	if (slv[i]==">Compound Names") vars_start<-i+1
	if (slv[i]==">Mechanism Rate Low expression -Kinetic or Elementary constants") vars_end<-i-1
	}

rhs<-slv[counter==38]
rhs<-gsub(";","#",rhs)
rhs<-gsub("//","#",rhs)
rhs<-gsub('[',"__",rhs,fixed=T)
rhs<-gsub("]","__",rhs)

par<-slv[counter==39]
par<-gsub(";","#",par)
par<-gsub("//","#",par)

vars<-slv[vars_start:vars_end]
vars<-gsub("#","",vars)

write.table(rhs, "RHS.temp.txt", quote =F, col.names =F,row.names =F)
write.table(par, "IV.temp.txt", quote =F, col.names =F,row.names =F)
write.table(vars, "variables.temp.txt", quote =F, col.names =F,row.names =F)
### end of reading SLV

################################  start second calculations from here ###################

### reading initials
initials0<-read.table("variables.temp.txt", sep="=", stringsAsFactors=F, comment.char="")
initials<-vector(mode="numeric", length=length(initials0[,1]))
names(initials)<-initials0[,1]

### reading parameters
params0<-read.table("IV.temp.txt", sep="=", stringsAsFactors=F, comment.char="#")
params1<-params0[!duplicated(params0[,1],fromLast=T),] #delete duplicated iv
params2<-params1[!(params1[,1] %in% names(initials)),] # exclude initials from iv
params<-params2[,2]
names(params)<-params2[,1]

### initializing variables
initials1<-params1[!(params1[,1] %in% names(params)),] # exclude not variables from iv
initials2<-initials1[,2]
names(initials2)<-initials1[,1]
initials<-ru.combine(initials,initials2)

### reading functions
fun<-read.table("RHS.temp.txt", sep="=", stringsAsFactors=F, comment.char="#")

######################### create .DLL from SLV ########################
### create .h file
mainLine1<- paste("/* file ", modelName, ".h */ \n", sep="")
mainLine1<- paste(mainLine1, "#define Npars ", length(params), "
#define Nout ", length(outs),"\n\n", sep="")
for (i in 1:length(params))
	mainLine1<- paste(mainLine1, "#define ", names(params)[i] , " parms[",i-1,"]\n", sep="") #parameters
mainLine1<-paste(mainLine1,"\n")
for (i in 1:length(initials))
	mainLine1<- paste(mainLine1, "#define ", names(initials)[i] , " y[",i-1,"]\n", sep="") #variables
mainLine1<-paste(mainLine1,"\n")
mainLine1<-paste(mainLine1,"\n")
#cat(mainLine1, file=paste(modelName,".h",sep=""))

### create .c file
mainLine2<- paste(mainLine1,"/* file pmn_ac4.c*/ 

#include <R.h> 
static double parms[Npars];

/* initializer */
void initmod(void (* odeparms)(int *, double *))
\t {
\t int N=Npars;
\t odeparms(&N,parms);
\t} \n
/* Derivatives and output variables */
void derivs (int *neq, double *t, double *y, double *ydot, double *yout, int *ip)
\t{
\t if (ip[0] <Nout) error(\"nout should be at least Nout\");
")
for (i in 1:length(fun[,1]))
	mainLine2<- paste(mainLine2, "\t double ", fun[i,1] , "=", fun[i,2], ";\n", sep="") #functions
for (i in 1:length(initials))
	mainLine2<-paste(mainLine2," \t ydot[",i-1, "] = F__",i,"__; \n", sep="")
if (length(outs)>0)
  for (i in 0:(length(outs)-1))
	  mainLine2<- paste(mainLine2, "\t yout[", i, "]=", outs[i], ";\n", sep="") #functions
mainLine2<-paste(mainLine2,"\t } \n", sep="")
cat(mainLine2, file=paste(modelName,".c",sep=""))

### create DLL
vvv <- paste("R CMD SHLIB ",modelName,".c", sep="")
system(vvv)
if (delTemp)
  file.remove(c("RHS.temp.txt","IV.temp.txt","variables.temp.txt",paste(modelName,".o",sep="")))

list(name=modelName, params=params, initials=initials, dll=modelName, outs=outs)
}