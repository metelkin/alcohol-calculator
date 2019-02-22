/* file al_07_05.h */ 
#define Npars 28
#define Nout 0

#define Default parms[0]
#define M parms[1]
#define M0 parms[2]
#define Vl70 parms[3]
#define Vm70 parms[4]
#define Vv70 parms[5]
#define GEN parms[6]
#define P parms[7]
#define R parms[8]
#define WCB_m parms[9]
#define WCB_f parms[10]
#define Height parms[11]
#define Age parms[12]
#define f_l parms[13]
#define f_m parms[14]
#define f_v parms[15]
#define GS70 parms[16]
#define a parms[17]
#define IWF70 parms[18]
#define PSs70 parms[19]
#define PSg70 parms[20]
#define Qs70 parms[21]
#define Qg70 parms[22]
#define Ql70 parms[23]
#define ADH_m parms[24]
#define ADH_f parms[25]
#define k_adh parms[26]
#define Km_l parms[27]
 
#define A_s y[0]
#define V_sf y[1]
#define V_sw y[2]
#define A_g y[3]
#define V_gf y[4]
#define V_gw y[5]
#define C_mb y[6]
#define C_vb y[7]
#define C_lb y[8]
#define C_rbb y[9]
 
 
 /* file pmn_ac4.c*/ 

#include <R.h> 
static double parms[Npars];

/* initializer */
void initmod(void (* odeparms)(int *, double *))
	 {
	 int N=Npars;
	 odeparms(&N,parms);
	} 

/* Derivatives and output variables */
void derivs (int *neq, double *t, double *y, double *ydot, double *yout, int *ip)
	{
	 if (ip[0] <Nout) error("nout should be at least Nout");
	 double f_rb = 0.01*(1.20*M/Height/Height + 0.23*Age - 10.8*GEN - 5.4);
	 double Vl=Vl70*pow((M/M0),0.87);
	 double Vm=Vm70*pow((M/M0),0.65);
	 double Vv=Vv70*pow((M/M0),0.65);
	 double GS=GS70*pow((M/M0),0.94);
	 double IWF=IWF70*pow((M/M0),0.94);
	 double PSs=PSs70*pow((M/M0),0.65);
	 double PSg=PSg70*pow((M/M0),0.65);
	 double Qs=Qs70*pow((M/M0),0.79);
	 double Qg=Qg70*pow((M/M0),0.79);
	 double Ql=Ql70*pow((M/M0),0.79);
	 double Vrb_eff=(M-Vm-Vl-Vv)*(f_rb*P+(1-f_rb)*(GEN*WCB_m+(1-GEN)*WCB_f))/R;
	 double Vl_eff=Vl*(f_l*P+1*0.75)/R;
	 double Vm_eff=Vm*(f_m*P+1*0.784)/R;
	 double Vv_eff=Vv*(f_v*P+1*0.718)/R;
	 double V_s=V_sf+V_sw+A_s*46/1000/789.3;
	 double V_g=V_gf+V_gw+A_g*46/1000/789.3;
	 double v_in_alc=0;
	 double v_in_fat=0;
	 double v_in_water=GS;
	 double v_alc=a*A_s;
	 double v_fat=a*V_sf;
	 double v_water=a*V_sw;
	 double v_out_fat=IWF*V_gf;
	 double v_out_water=IWF*V_gw;
	 double C_sw=A_s/(V_sf*P+V_sw);
	 double v_diff_st=PSs*(C_sw-C_mb/R);
	 double C_gw=A_g/(V_gf*P+V_gw);
	 double v_diff_g=PSg*(C_gw-C_vb/R);
	 double v_st_liv=Qs*C_mb;
	 double v_g_liv=Qg*C_vb;
	 double v_liv_rb=(Ql+Qs+Qg)*C_lb;
	 double v_rb_st=Qs*C_rbb;
	 double v_rb_g=Qg*C_rbb;
	 double v_rb_liv=Ql*C_rbb;
	 double v_cl=(ADH_m*GEN+(1-GEN)*ADH_f)*k_adh*C_lb/R/(Km_l+C_lb/R);
	 double F__1__=(v_in_alc-v_alc-v_diff_st)/Default;
	 double F__2__=(v_in_fat-v_fat)/Default;
	 double F__3__=(v_in_water-v_water)/Default;
	 double F__4__=(v_alc-v_diff_g)/Default;
	 double F__5__=(v_fat-v_out_fat)/Default;
	 double F__6__=(v_water-v_out_water)/Default;
	 double F__7__=(v_diff_st-v_st_liv+v_rb_st)/Vm_eff;
	 double F__8__=(v_diff_g-v_g_liv+v_rb_g)/Vv_eff;
	 double F__9__=(v_st_liv+v_g_liv-v_liv_rb+v_rb_liv-v_cl)/Vl_eff;
	 double F__10__=(v_liv_rb-v_rb_st-v_rb_g-v_rb_liv)/Vrb_eff;
	 double promille=C_rbb*46/789.3;
	 double percent=promille/10;
	 double A_gramm=A_s/1e3*46;
	 double Alc_b=46*(C_rbb*Vrb_eff+C_lb*Vl_eff+C_mb*Vm_eff+C_vb*Vv_eff);
	 double V_tot=Vrb_eff+Vl_eff+Vm_eff+Vv_eff;
	 double BrAC=percent/210*1000;
 	 ydot[0] = F__1__; 
 	 ydot[1] = F__2__; 
 	 ydot[2] = F__3__; 
 	 ydot[3] = F__4__; 
 	 ydot[4] = F__5__; 
 	 ydot[5] = F__6__; 
 	 ydot[6] = F__7__; 
 	 ydot[7] = F__8__; 
 	 ydot[8] = F__9__; 
 	 ydot[9] = F__10__; 
	 } 
