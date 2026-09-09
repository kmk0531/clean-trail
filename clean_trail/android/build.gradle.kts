allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
subprojects {
    project.evaluationDependsOn(":app")
}

// 일부 플러그인(tflite_flutter 등)이 Kotlin 컴파일 타겟만 지정하고
// Java 컴파일 타겟은 기본값(11)으로 남겨두어 발생하는
// "Inconsistent JVM Target Compatibility" 빌드 오류를 방지하기 위해
// 플러그인 서브프로젝트의 Java/Kotlin 타겟을 앱과 동일한 17로 통일한다.
// (:app 모듈은 자체 build.gradle.kts에서 이미 17로 설정되어 있고,
//  이 시점엔 이미 평가가 끝나 afterEvaluate를 걸 수 없으므로 제외한다.)
subprojects {
    if (project.path == ":app") return@subprojects
    afterEvaluate {
        extensions.findByType(com.android.build.gradle.BaseExtension::class.java)?.apply {
            compileOptions {
                sourceCompatibility = JavaVersion.VERSION_17
                targetCompatibility = JavaVersion.VERSION_17
            }
        }
        tasks.withType<org.jetbrains.kotlin.gradle.tasks.KotlinCompile>().configureEach {
            compilerOptions {
                jvmTarget.set(org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17)
            }
        }
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
