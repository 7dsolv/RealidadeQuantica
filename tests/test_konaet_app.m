function report = test_konaet_app(root,output)
%TEST_KONAET_APP Controles reais e retomada de falha de sensor na interface.
fig=abrir_konaet(ModelFolder=fullfile(output,'model'),Visible='off',AutoStart=false);
guard=onCleanup(@() close(fig)); %#ok<NASGU>
tests=struct('name',{},'passed',{});
callbacks=fig.UserData;
for k=1:35, callbacks.step(); end
assert(fig.UserData.state.samples==35 && isfinite(fig.UserData.view.node_V));
assert(fig.UserData.view.class>=0);tests(end+1)=struct('name','live_circuit_and_inference','passed',true);
step=findobj(fig,'Tag','konaet-step');step.Value=true;
before=fig.UserData.view.node_V;for k=1:15,callbacks.step();end
assert(fig.UserData.view.node_V>before+0.5);tests(end+1)=struct('name','step_control_changes_circuit','passed',true);
drop=findobj(fig,'Tag','konaet-dropout');drop.Value=true;callbacks.step();
assert(fig.UserData.view.class==-1);tests(end+1)=struct('name','sensor_fault_is_invalid','passed',true);
drop.Value=false;for k=1:33,callbacks.step();end
assert(fig.UserData.view.class>=0);tests(end+1)=struct('name','sensor_window_recovers','passed',true);
exportapp(fig,fullfile(output,'konaet-app.png'));
callbacks.reset();assert(fig.UserData.state.samples==1);tests(end+1)=struct('name','reset_preserves_app','passed',true);
report=struct('source_revision',getenv('GITHUB_SHA'),'passed',numel(tests),'failed',0,'total',numel(tests),'tests',tests);
konaet_write_json(fullfile(output,'app-report.json'),report);
end
