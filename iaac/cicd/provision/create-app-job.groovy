import jenkins.model.Jenkins
import hudson.plugins.git.GitSCM
import hudson.plugins.git.BranchSpec
import hudson.plugins.git.extensions.impl.*
import org.jenkinsci.plugins.workflow.cps.CpsScmFlowDefinition
import org.jenkinsci.plugins.workflow.job.WorkflowJob

def jenkinsInstance = Jenkins.getInstance()
def jobName = 'app'
def scmUrl = 'https://github.com/bebyx/azure-madness.git'
def branch = 'master'
def jenkinsfilePath = 'app/Jenkinsfile'


// Check if the job already exists
def existingJob = jenkinsInstance.getItem(jobName)
if (existingJob == null) {
    // Create a new Pipeline job
    def pipelineJob = jenkinsInstance.createProject(WorkflowJob, jobName)

    // Configure SCM
    def scm = new GitSCM(scmUrl)
    scm.branches = [new BranchSpec("*/master")];

    // Define the Jenkinsfile location within the SCM
    def definition = new CpsScmFlowDefinition(scm, jenkinsfilePath)
    definition.setLightweight(true)
    pipelineJob.setDefinition(definition)

    // Save the job configuration
    pipelineJob.save()
    println("Pipeline job '${jobName}' created and SCM configured successfully.")
} else {
    println("Job '${jobName}' already exists.")
}
