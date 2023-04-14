extends "res://addons/gut/hook_script.gd"

const Coverage = preload("res://addons/coverage/Coverage.gd")
const Other = preload("../Other.gd")

const COVERAGE_TARGET := 74.0
const FILE_TARGET := 33.0

func run():
	var coverage = Coverage.instance()
	var coverage_file := OS.get_environment("COVERAGE_FILE") if OS.has_environment("COVERAGE_FILE") else ""
	if coverage_file:
		coverage.save_coverage_file(coverage_file)
	coverage.set_coverage_targets(COVERAGE_TARGET, FILE_TARGET)
	var verbosity = Coverage.Verbosity.FailingFiles
	var logger = gut.get_logger()
	var other := Other.new()
	assert(Other.source_code.match("*Coverage.gd*"), "Other script should be instrumented")

	coverage.finalize(verbosity)

	var coverage_passing = coverage.coverage_passing()

	if !coverage_passing:
		logger.failed("Coverage target of %.1f%% total (%.1f%% file) was not met" % [COVERAGE_TARGET, FILE_TARGET])
		set_exit_code(2)
	else:
		logger.passed("Coverage target of %.1f%% total, %.1f%% file coverage" % [COVERAGE_TARGET, FILE_TARGET])
