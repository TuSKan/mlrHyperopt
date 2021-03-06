context("ParConfig")

test_that("ParConfig spots mistakes", {
  par.set = makeParamSet(
    makeNumericParam(id = "cost",  upper = 15, lower = 0),
    makeDiscreteParam(id = "kernel", values = c("polynomial", "radial")),
    makeIntegerParam(id = "degree", default = 3L, lower = 1L, requires = quote(kernel=="polynomial")),
    makeNumericParam(id = "gamma", lower = -5, upper = 5, trafo = function(x) 2^x))

  par.set.out.of.bound = makeParamSet(
    makeNumericParam(id = "cost", upper = 10, lower = -10)
  )

  par.set.tolerance = makeNumericParamSet("tolerance", lower = 0.01, upper = 0.1)

  par.vals.empty = list()
  par.vals.good = list(cachesize = 100L, tolerance = 0.01)
  par.vals.bad = list(foo = "bar")
  par.vals.conflict = list(cost = 2)

  lrn.good = "classif.svm"
  lrn.bad = "classif.randomForest"
  lrn.specified = makeLearner("classif.svm", tolerance = 0.05)

  par.config = makeParConfig(par.set)
  expect_class(par.config, "ParConfig")
  expect_equal(getParConfigParSet(par.config), par.set)
  expect_equal(getParConfigParVals(par.config), list())
  expect_null(getParConfigLearnerClass(par.config))
  expect_output(print(par.config), "Parameter Configuration")

  par.config = makeParConfig(par.set, learner = lrn.good)
  expect_equal(getParConfigLearnerClass(par.config), lrn.good)

  par.config = makeParConfig(par.set, par.vals = par.vals.bad)
  expect_equal(getParConfigParVals(par.config), par.vals.bad)

  par.config = makeParConfig(par.set, lrn.good, par.vals = par.vals.good)
  expect_equal(getParConfigParSet(par.config), par.set)
  expect_equal(getParConfigParVals(par.config), par.vals.good)
  expect_equal(getParConfigLearnerClass(par.config), lrn.good)

  par.config = makeParConfig(par.set.tolerance, learner = lrn.specified)
  expect_equal(getParConfigParSet(par.config), par.set.tolerance)
  expect_equal(getParConfigParVals(par.config), list())
  expect_equal(getParConfigLearnerClass(par.config), getLearnerClass(lrn.specified))


  expect_error(makeParConfig(par.set, lrn.bad, par.vals = par.vals.good), "Params that are not supported by the Learner: cost")
  expect_error(makeParConfig(par.set, lrn.good, par.vals = par.vals.conflict), "Following par.vals are set to a specific value and conflict with the tuning par.set: cost=2")
  expect_warning({par.config = makeParConfig(par.set, lrn.specified, par.vals = par.vals.good)}, "The learners default par.vals tolerance")
  expect_equal(par.vals.good, getParConfigParVals(par.config)[names(par.vals.good)])
  #TODO
  # expect_error(makeParConfig(par.set.out.of.bound, lrn.good), "Params that are out of bound: cost")
})

test_that("ParConfig getters/setters work", {
  par.set = makeParamSet(
    makeNumericParam(id = "cost",  upper = 15, lower = 0)
    )
  lrn.good = makeLearner("classif.svm")
  lrn.okay = makeLearner("regr.svm")
  lrn.bad = makeLearner("classif.randomForest")

  par.config = makeParConfig(par.set, lrn.good)
  par.config2 = setParConfigLearnerType(par.config, "regr")
  expect_equal(getParConfigLearnerClass(par.config2), getLearnerClass(lrn.okay))
  par.config3 = setParConfigLearner(par.config, lrn.okay)
  expect_equal(getParConfigLearnerClass(par.config3), getLearnerClass(lrn.okay))

  expect_error(setParConfigLearner(par.config, lrn.bad), "Params that are not supported by the Learner")
})

test_that("generate ParConfig works", {
  tasks = list(classif = iris.task, regr = bh.task)
  learners = makeLearners(c("regr.randomForest", "classif.svm"))
  for (learner in learners) {
    task = tasks[[getLearnerType(learner)]]
    par.config = generateParConfig(learner = learner, task = task)
    expect_class(par.config, "ParConfig")
  }
  expect_error(generateParConfig(task = tasks[["classif"]], learner = "classif.binomial"), "no default")
})
