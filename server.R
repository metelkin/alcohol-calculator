source("aux fun.R")
require(deSolve)

## create model ##
#MODEL <- ru.import.slv("al_07_05")		# import model from .SLV
#save model ##
#save(MODEL,file="alc model.rumod") 
## open model ##
load("alc model.rumod")             #load model
## load model ##
dyn.load(paste0(MODEL$dll,.Platform$dynlib.ext))  	# load .DLL

shinyServer(function(input, output, session) {
  data<-reactive({ ###BAC_in
    inFile <- input$file1
    if (is.null(inFile))
      return(NULL)  
    read.csv(inFile$datapath, header = TRUE, sep=',')
  })
  
	BACresult <- reactive({
    onPortion<-c(T,input$add1,input$add2 & input$add1,input$add3 & input$add2 & input$add1)
    timePortion<-60*c(input$d_time,input$d_time1,input$d_time2,input$d_time3)[onPortion]
    APortion<-1/100*0.7893*1e3/46*c(input$volume,input$volume1,input$volume2,input$volume3)[onPortion]*c(input$proof,input$proof1,input$proof2,input$proof3)[onPortion]
    orderPortion<-order(timePortion)
    
    min_time <- min(timePortion)
    max_time <- max(timePortion)
    
    eventdat <- data.frame(var = "A_g", time = timePortion, value = APortion, method = "add")[orderPortion,]
    
    #cat(orderPortion, "\n")
		
		#Widmark's max. concentration in blood
		A_all <- sum(APortion)/1e3*46/input$weight/0.6
		
		# setting new parameters
		sex_new <-switch(input$sex, "1"=1, "0"=0)
		params_new <- c(M=input$weight, Height=input$height/100, Age=input$age, GEN=sex_new)
		MODEL$params[names(params_new)] <- params_new
  
		
		# time interval for ODE solving
#		ifelse( input$fit_button == F, {
			times <- c(seq(min_time, input$time_scale*60+min_time, 1), eventdat$time)
			times <- sort(unique(times))
			# ODE solving
			out <- ode(y = MODEL$initials, times = times, func = "derivs", parms = MODEL$params, dllname=MODEL$dll, initfunc = "initmod", events = list (data=eventdat))
		  out <- as.data.frame (out)
			out$max_time <- input$time_scale*60+min_time
			out$min_time <- min_time			
			return (out)
#			},
#			{
#			return(NULL)
#			})
		})
		
		#### making the plot
	output$BACplot <- renderPlot ({
		out <- BACresult()
		promille <- c(out$C_rbb*46/789.3)
		C_rbb_max <- round ( max(promille), 2)
    
		plot(y = promille, x = out$time/60, type = "l", xlab="time, hours",  xlim = c(out$min_time[1]/60, out$max_time[1]/60), ylim=c(0, max(C_rbb_max,0.35)), xaxt = 'n',main=paste ("Max concentration in blood: ", C_rbb_max," promille") ) #
		temp1<-seq(round(out$min_time[1]/60), round(out$max_time[1]/60))
    temp2<-paste(temp1-24*floor(temp1/24),":00", sep = "")
    axis (side = 1 , at = temp1, labels=temp2)
		#axis (side = 1 , at = temp1-0.5, labels=F)
  	abline(h=0.35, col="green")
    #add experimental
    points (x = data()$time/60, y= data()$BrAC)
					
	})
	
	output$Fit<-renderText ({
		ifelse ( input$sex ==1, return(MODEL$params["ADH_m"]), return(MODEL$params["ADH_f"]) )
	})
	
	output$BACtable <- renderTable ({
	data()
	})

})