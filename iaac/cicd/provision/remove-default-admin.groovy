import jenkins.model.*
import hudson.security.*

def instance = Jenkins.getInstance()

def securityRealm = instance.getSecurityRealm()
if (securityRealm instanceof HudsonPrivateSecurityRealm) {
    def user = securityRealm.getUser("admin")
    if (user) {
        user.delete()
        println("User 'admin' has been deleted.")
    } else {
        println("User 'admin' not found.")
    }
} else {
    println("The security realm is not HudsonPrivateSecurityRealm; cannot delete users programmatically.")
}

instance.save()
