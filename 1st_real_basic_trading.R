
#Set initialization date and dates you want to backtest the strategy
start_date <- as.Date("2017-02-01")
end_date <- as.Date("2018-06-24")
init_date <- as.Date("2017-01-31")
init_equity <- "50000"
adjustment <- TRUE


#Set the tickers you would like in the portfolio
symbol <- "SPY"
getSymbols(symbol, src = "yahoo",from = start_date, to=end_date, adjust = adjustment)

#Name portfolio, account, and strategy
portfolio.st <- "basic_port"
account.st <- "basic_account"
strategy.st <- "basic_strategy"

#remove any current strategies already in portfolio
rm.strat(portfolio.st)
rm.strat(account.st)

#Initialize the portfolio
stock(symbol, currency = currency("USD"), multiplier = 1)
initPortf(name = portfolio.st, symbols = symbol, initDate = init_date)
initAcct(name = account.st, portfolios = portfolio.st, initDate = init_date, initEq =init_equity)
initOrders(portfolio.st, symbol, init_date)
strategy(strategy.st, store = TRUE)


#Add indicators such as the 50 and 20 MA
add.indicator(strategy = strategy.st, name = "SMA", arguments = list(x = quote(Cl(mktdata)), n=20), label ="nFast")
add.indicator(strategy = strategy.st, name = "SMA", arguments = list(x = quote(Cl(mktdata)), n=50), label = "nSlow")

#Add Signals for the indicators
add.signal(strategy = strategy.st, name= "sigCrossover", arguments =  list(columns = c("nFast", "nSlow"), relationship = "gte"), label = "long")
add.signal(strategy = strategy.st, name= "sigCrossover", arguments =  list(columns = c("nFast", "nSlow"), relationship = "lt"), label = "short")

#Add rules for entering positions
#enter long position
add.rule(strategy.st, 
         name = "ruleSignal", 
         arguments = list(sigcol = "long",
                          sigval = TRUE,
                          orderqty = 100,
                          ordertype = "market",
                          TxnFees = -.5,
                          replace = FALSE),
         type = "enter",
         label = "EnterLong")

#enter short position
add.rule(strategy.st,
         name = "ruleSignal",
         arguments = list(sigcol = "short",
                          sigval = TRUE,
                          orderqty = -100,
                          ordertype = "market", 
                          TxnFees = -.5,
                          replace = FALSE),
         type = "enter",
         label = "EnterShort")

#Add rules for exiting opened postions
#exit long positions
add.rule(strategy.st, 
         name = "ruleSignal", 
         arguments = list(sigcol = "short", 
                          sigval = TRUE, 
                          orderside = "long", 
                          ordertype = "market", 
                          orderqty = "all", 
                          TxnFees = -.5, 
                          replace = TRUE), 
         type = "exit", 
         label = "Exit2SHORT")

#exit short positions
add.rule(strategy.st, 
         name = "ruleSignal", 
         arguments = list(sigcol = "long", 
                          sigval = TRUE, 
                          orderside = "short", 
                          ordertype = "market", 
                          orderqty = "all", 
                          TxnFees = -.5, 
                          replace = TRUE), 
         type = "exit", 
         label = "Exit2LONG")

#Apply strategy
applyStrategy(strategy.st, portfolios = portfolio.st,debug = TRUE)
updatePortf(portfolio.st)
updateAcct(account.st)
updateEndEq(account.st)


#Chart the results of your strategy
chart.Posn(portfolio.st, Symbol = symbol, Dates="2017-01-01/2018-06-24", 
           TA="add_SMA(n = 20, col = 2); add_SMA(n = 50, col = 4)")


#Set the stats to do further analysis
stats  <- tradeStats(portfolio.st)

