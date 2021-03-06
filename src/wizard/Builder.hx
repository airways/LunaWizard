package wizard;

import js.node.Path;
import sys.io.File;
import sys.FileSystem;
import napkin.Napkin;
import wizard.utils.Logger;

using StringTools;

class Builder {
  private static var _log: Logger = new Logger();
  public static var path: String = Sys.getCwd();
  public static var programDir = Path.dirname(Sys.programPath());
  private static var _scaffoldDir = '${Path.dirname(programDir)}/scaffold';

  public static function newProject(?path: String) {
    if (path != null && path != '') {
      Sys.setCwd(Path.resolve(path));
    }

    addSrcDirectory(Sys.getCwd());
    addMainHaxeFile(Sys.getCwd());
    addParamsFile(Sys.getCwd());
    addGamesDirectory(Sys.getCwd());
    addCheckstyleJson(Sys.getCwd());
    addHaxeFormatJson(Sys.getCwd());
    addCompileHxml(Sys.getCwd());
    _log.info('Static project files successfully created');
  }

  public static function addSrcDirectory(path: String) {
    if (!FileSystem.exists('${path}/src')) {
      FileSystem.createDirectory('${path}/src');
    }
  }

  public static function addMainHaxeFile(path: String) {
    var filePath = '${path}/src/Main.hx';
    if (!FileSystem.exists(filePath)) {
      var mainPath = '${_scaffoldDir}/Main.hx';
      var fileData: String = File.getContent(mainPath);
      File.saveContent(filePath, fileData);
    }
  }

  public static function addParamsFile(path: String) {
    var filePath = '${path}/src/Params.js';
    if (!FileSystem.exists(filePath)) {
      var paramsPath = '${_scaffoldDir}/Params.js';
      var fileData: String = File.getContent(paramsPath);
      File.saveContent(filePath, fileData);
    }
  }

  public static function addGamesDirectory(path: String) {
    if (!FileSystem.exists('${path}/games')) {
      FileSystem.createDirectory('${path}/games');
      FileSystem.createDirectory('${path}/games/mv');
      FileSystem.createDirectory('${path}/games/mz');
    }
  }

  public static function addCheckstyleJson(path: String) {
    if (!FileSystem.exists('${path}/checkstyle.json')) {
      var jsonPath = '${_scaffoldDir}/checkstyle.json';
      var fileData: String = File.getContent(jsonPath).toString();

      File.saveContent('${path}/checkstyle.json', fileData);
    }
  }

  public static function addHaxeFormatJson(path: String) {
    if (!FileSystem.exists('${path}/hxformat.json')) {
      var jsonPath = '${_scaffoldDir}/hxformat.json';
      var fileData: String = File.getContent(jsonPath).toString();

      File.saveContent('${path}/hxformat.json', fileData);
    }
  }

  public static function addCompileHxml(path: String) {
    if (!FileSystem.exists('${path}/compile.hxml')) {
      var jsonPath = '${_scaffoldDir}/compile.hxml';
      var fileData: String = File.getContent(jsonPath);

      File.saveContent('${path}/compile.hxml', fileData);
    }
  }

  public static function addReadMe(path: String) {
    var filePath = '${path}/README.md';
    if (!FileSystem.exists(filePath)) {
      var readmePath = '${_scaffoldDir}/README.md';
      var fileData: String = File.getContent(readmePath);
      File.saveContent(filePath, fileData);
    }
  }

  public static function fileBanner(filename) {
    var date = Date.now();
    return '/** ============================================================================
 *
 *  ${filename}
 * 
 *  Build Date: ${date.getMonth() + 1}/${date.getDate()}/${date.getFullYear()}
 * 
 *  Made with LunaTea -- Haxe
 *
 * =============================================================================
*/
';
  };

  public static function installRequiredPackages() {
    var napkin = NodePackage.install('@lunatechs/lunatea-napkin', true);
    var lix = NodePackage.install('lix');
    _log.spawnResult(napkin, 'Installed lunatea-napkin', 'Unable to install lunatea-napkin');
    _log.spawnResult(lix, 'Installed lix', 'Unable to install lix');
    if (lix.status) {
      LixPackage.init();
      var lunaTea = LixPackage.installFromGithub('LunaTechsDev', 'LunaTea');
      _log.spawnResult(lunaTea, 'Installed LunaTea', 'Unable to install LunaTea');
    }
  }

  public static function compileFromSource(?hxmlPath: String, ?usePrettier = true, ?removeUnusedClasses = true) {
    var lix = LixPackage.compile(hxmlPath);
    _log.spawnResult(lix, 'Succesfully compiled from hxml', 'Unable to compile from hxml');
    if (lix.status) {
      var hxmlData = File.getContent(hxmlPath);
      var ereg = new EReg('(-js|--js)(.*)', 'g');
      var matches = Utils.getMatches(ereg, hxmlData, 2);
      var jsTargetPaths = matches.map((path: String) -> {
        return path.trim();
      });

      for (path in jsTargetPaths) {
        var code = File.getContent(Path.resolve(path));
        try {
          var filename = Path.parse(path).name;
          File.saveContent(path, '${fileBanner(filename)} ${Napkin.parse(code, {
            usePrettier: usePrettier,
            removedUnusedClasses: removeUnusedClasses
          })}');
        } catch (error: js.lib.Error) {
          _log.prettyError(error);
        }
      }
    }
  }
}
