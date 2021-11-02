import gulp from 'gulp';
import babel from 'gulp-babel';

const build = () => {
  const globs = [
    "src/**/*.ts",
    "src/**/*.js",
  ];
  return gulp.src(globs)
    .pipe(babel())
    .pipe(gulp.dest("dist"));
};

const watch = () => {
  const globs = [
    "src/**/*.ts",
    "src/**/*.js",
    ".env",
    ".babelrc",
    "tsconfig.json",
  ];
  return gulp.watch(globs, build);
};

const dev = gulp.series(build, watch);

export {
  build,
  watch,
  dev,
};
