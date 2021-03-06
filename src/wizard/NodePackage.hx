package wizard;

import wizard.utils.ChildSpawn;
import haxe.Json;
import sys.FileSystem;
import sys.io.File;

class NodePackage {
  public static function createPackageJson() {
    var path: String = '${Sys.getCwd()}/package.json';
    var packageData = {
      name: 'luna-plugin',
      version: '1.0.0'
    };

    if (!FileSystem.exists(path)) {
      File.saveContent(path, Json.stringify(packageData));
    }
  }

  public static function npx(command, args: Array<String>): SpawnResult {
    args.unshift(command);
    return ChildSpawn.run('npx', args);
  }

  public static function install(name: String, ?asDev: Bool = false): SpawnResult {
    var args = ['install', '--save', name];
    if (asDev) {
      args.push('-D');
    }
    
    return ChildSpawn.run('npm', args);
  }
}
