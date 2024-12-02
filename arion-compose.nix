{ pkgs, ... }:
let
  runningInProduction = false;
in
{
  project.name = "k4_devops_pr4";
  services.api = {
    image = {
      contents = with pkgs; [
        bash
        coreutils
        nodejs
        api
      ];
      command = [
        "sh"
        "-c"
        ''
          npm config set prefix /
          npm start --prefix /lib/node_modules/api
        ''
      ];
    };
    service = {
      depends_on = [ "mysql" ];
      ports = [ "5555:5000" ];
      stop_signal = "SIGINT";
      restart = "always";
    };
    service.useHostStore = !runningInProduction;
  };
  services.frontend = {
    image = {
      contents = with pkgs; [
        python3
        frontend
      ];
      command = [
        "python3"
        "-m"
        "http.server"
        "-d"
        "/srv/dist"
      ];
    };
    service = {
      #depends_on = [ "api" ];
      ports = [ "8954:8000" ];
      stop_signal = "SIGINT";
    };
    service.useHostStore = !runningInProduction;
  };
  services.mysql = {
    service = {
      image = "mysql";
      environment = {
        MYSQL_ROOT_PASSWORD = "password";
        MYSQL_DATABASE = "time_db";
      };
    };
  };
  services.adminer = {
    service = {
      image = "adminer";
      ports = [
        "8914:8080"
      ];
    };
  };
}
